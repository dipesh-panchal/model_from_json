import 'dart:convert';
import 'dart:io';

/// ============================================================
/// ✅ Registry holding all generated models
///
/// Key   → filename (snake_case)
/// Value → Dart source code
///
/// Example:
///   "user_model.dart" → "class UserModel {...}"
/// ============================================================
final Map<String, String> generatedModels = {};

/// ============================================================
/// ✅ Main Generator Entry Point
///
/// Supports:
/// ------------------------------------------------------------
/// ✅ Nested Objects
/// ✅ List<NestedObjects>
/// ✅ Primitive Fields
/// ✅ Optional Output Directory
///
/// Usage:
/// ------------------------------------------------------------
/// runGenerator(
///   jsonPath: "complex.json",
///   rootClassName: "UserModel",
///   outputDir: "lib/models"
/// )
///
/// If outputDir is not provided → files are written in current dir.
/// ============================================================
void runGenerator({
  required String jsonPath,
  required String rootClassName,
  String outputDir = ".",
}) {
  /// ✅ Reset registry every run
  generatedModels.clear();

  // ------------------------------------------------------------
  // 1️⃣ Validate JSON file
  // ------------------------------------------------------------
  final file = File(jsonPath);

  if (!file.existsSync()) {
    throw Exception("❌ File not found: $jsonPath");
  }

  // ------------------------------------------------------------
  // 2️⃣ Ensure Output Folder Exists
  // ------------------------------------------------------------
  final outFolder = Directory(outputDir);

  if (!outFolder.existsSync()) {
    outFolder.createSync(recursive: true);
  }

  // ------------------------------------------------------------
  // 3️⃣ Decode JSON
  // ------------------------------------------------------------
  final jsonString = file.readAsStringSync();
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

  // ------------------------------------------------------------
  // 4️⃣ Generate Models Recursively
  // ------------------------------------------------------------
  generateModel(rootClassName, jsonMap);

  // ------------------------------------------------------------
  // 5️⃣ Write Generated Files
  // ------------------------------------------------------------
  print("✅ Done! Generated ${generatedModels.length} model files:\n");

  for (final entry in generatedModels.entries) {
    final filePath = outputDir == "."
        ? entry.key
        : "$outputDir${Platform.pathSeparator}${entry.key}";

    File(filePath).writeAsStringSync(entry.value);

    print("📄 $filePath");
  }

  print("\n🎉 Done!\n");
}

/// ============================================================
/// ✅ Recursive Model Generator
///
/// Creates a Dart model class and stores it inside `generatedModels`.
///
/// Handles:
/// ✅ Nested objects → Child model files
/// ✅ Lists of objects → List<ChildModel>
/// ✅ Primitive inference
/// ============================================================
void generateModel(String className, Map<String, dynamic> json) {
  final buffer = StringBuffer();

  // Convert class name → filename
  final fileName = "${camelToSnake(className)}.dart";

  // Prevent duplicate generation
  if (generatedModels.containsKey(fileName)) return;

  final fields = <Map<String, String>>[];

  // ------------------------------------------------------------
  // 1️⃣ Extract Fields
  // ------------------------------------------------------------
  for (final entry in json.entries) {
    final jsonKey = entry.key;
    final fieldName = snakeToCamel(jsonKey);

    String dartType;
    String defaultValue;

    // ✅ Nested Object Case
    if (entry.value is Map) {
      final childClassName =
          fieldName[0].toUpperCase() + fieldName.substring(1);

      generateModel(childClassName, entry.value as Map<String, dynamic>);

      dartType = childClassName;
      defaultValue = "$childClassName.fromJson({})";
    }
    // ✅ List of Nested Objects Case
    else if (entry.value is List &&
        entry.value.isNotEmpty &&
        entry.value.first is Map) {
      final childClassName =
          fieldName[0].toUpperCase() + fieldName.substring(1);

      generateModel(childClassName, entry.value.first as Map<String, dynamic>);

      dartType = "List<$childClassName>";
      defaultValue = "const []";
    }
    // ✅ Primitive Field Case
    else {
      dartType = inferDartType(entry.value);
      defaultValue = inferDefaultValue(entry.value);
    }

    fields.add({
      "jsonKey": jsonKey,
      "fieldName": fieldName,
      "dartType": dartType,
      "default": defaultValue,
    });
  }

  // ------------------------------------------------------------
  // 2️⃣ Imports
  // ------------------------------------------------------------
  buffer.writeln("import 'package:equatable/equatable.dart';");

  for (final field in fields) {
    final type = field["dartType"]!;

    // Import nested object
    if (isCustomModel(type)) {
      buffer.writeln("import '${camelToSnake(type)}.dart';");
    }

    // Import List<NestedObject>
    if (type.startsWith("List<")) {
      final inner = type.replaceAll("List<", "").replaceAll(">", "");

      if (isCustomModel(inner)) {
        buffer.writeln("import '${camelToSnake(inner)}.dart';");
      }
    }
  }

  buffer.writeln("");

  // ------------------------------------------------------------
  // 3️⃣ Class Definition
  // ------------------------------------------------------------
  buffer.writeln("class $className extends Equatable {");

  for (final field in fields) {
    buffer.writeln("  final ${field["dartType"]} ${field["fieldName"]};");
  }

  // Constructor
  buffer.writeln("\n  const $className({");
  for (final field in fields) {
    buffer.writeln("    required this.${field["fieldName"]},");
  }
  buffer.writeln("  });");

  // ------------------------------------------------------------
  // 4️⃣ fromJson
  // ------------------------------------------------------------
  buffer.writeln(
    "\n  factory $className.fromJson(Map<String, dynamic> json) {",
  );
  buffer.writeln("    return $className(");

  for (final field in fields) {
    final type = field["dartType"]!;
    final key = field["jsonKey"]!;
    final name = field["fieldName"]!;
    final def = field["default"]!;

    // Nested object
    if (isCustomModel(type)) {
      buffer.writeln("      $name: $type.fromJson(json['$key'] ?? {}),");
    }
    // List<NestedObject>
    else if (type.startsWith("List<")) {
      final inner = type.replaceAll("List<", "").replaceAll(">", "");

      if (isCustomModel(inner)) {
        buffer.writeln(
          "      $name: (json['$key'] as List? ?? [])"
          ".map((e) => $inner.fromJson(e))"
          ".toList(),",
        );
      } else {
        buffer.writeln("      $name: json['$key'] as $type? ?? $def,");
      }
    }
    // Primitive
    else {
      buffer.writeln("      $name: json['$key'] as $type? ?? $def,");
    }
  }

  buffer.writeln("    );");
  buffer.writeln("  }");

  // ------------------------------------------------------------
  // 5️⃣ toJson
  // ------------------------------------------------------------
  buffer.writeln("\n  Map<String, dynamic> toJson() => {");

  for (final field in fields) {
    buffer.writeln("        '${field["jsonKey"]}': ${field["fieldName"]},");
  }

  buffer.writeln("      };");

  // ------------------------------------------------------------
  // 6️⃣ Equatable props
  // ------------------------------------------------------------
  buffer.writeln("\n  @override");
  buffer.writeln("  List<Object> get props => [");

  for (final field in fields) {
    buffer.writeln("        ${field["fieldName"]},");
  }

  buffer.writeln("      ];");

  buffer.writeln("}");

  // Save model
  generatedModels[fileName] = buffer.toString();
}

// ============================================================
// ✅ HELPERS
// ============================================================

bool isCustomModel(String type) {
  return type[0].toUpperCase() == type[0] &&
      !["String", "int", "double", "bool"].contains(type) &&
      !type.startsWith("List");
}

String snakeToCamel(String input) {
  final parts = input.split('_');
  return parts.first +
      parts.skip(1).map((w) => w[0].toUpperCase() + w.substring(1)).join();
}

String camelToSnake(String input) {
  return input
      .replaceAllMapped(
        RegExp(r'[A-Z]'),
        (m) => '_${m.group(0)!.toLowerCase()}',
      )
      .replaceFirst('_', '');
}

String inferDartType(dynamic value) {
  if (value is int) return "int";
  if (value is double) return "double";
  if (value is bool) return "bool";

  if (value is List) {
    if (value.isEmpty) return "List<dynamic>";
    final first = value.first;

    if (first is String) return "List<String>";
    if (first is int) return "List<int>";
    if (first is double) return "List<double>";
    if (first is bool) return "List<bool>";

    return "List<dynamic>";
  }

  return "String";
}

String inferDefaultValue(dynamic value) {
  if (value is int) return "0";
  if (value is double) return "0.0";
  if (value is bool) return "false";
  if (value is List) return "const []";
  return "''";
}
