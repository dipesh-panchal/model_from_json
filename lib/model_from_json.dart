import 'dart:convert';
import 'dart:io';

/// ============================================================
/// ✅ Registry holding all generated models
///
/// Key   → filename (snake_case)
/// Value → Dart source code
/// ============================================================
final Map<String, String> generatedModels = {};

/// ============================================================
/// ✅ Main Generator Entry Point
/// ============================================================
void runGenerator({
  required String jsonPath,
  required String rootClassName,
  String outputDir = ".",
}) {
  generatedModels.clear();

  final file = File(jsonPath);
  if (!file.existsSync()) {
    throw Exception("❌ File not found: $jsonPath");
  }

  /// Ensure output folder exists
  final outFolder = Directory(outputDir);
  if (!outFolder.existsSync()) {
    outFolder.createSync(recursive: true);
  }

  /// Decode JSON
  final jsonString = file.readAsStringSync();
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

  /// Generate recursively
  generateModel(toPascalCase(rootClassName), jsonMap);

  print("✅ Done! Generated ${generatedModels.length} model files:\n");

  /// Write output files
  for (final entry in generatedModels.entries) {
    final filePath = outputDir == "."
        ? entry.key
        : "$outputDir${Platform.pathSeparator}${entry.key}";

    File(filePath).writeAsStringSync(entry.value);
    print("📄 $filePath");
  }

  print("\n🎉 Finished Successfully!\n");
}

/// ============================================================
/// ✅ Recursive Model Generator
/// ============================================================
void generateModel(String className, Map<String, dynamic> json) {
  className = toPascalCase(className);

  final buffer = StringBuffer();
  final fileName = "${camelToSnake(className)}.dart";

  /// Prevent duplicate generation
  if (generatedModels.containsKey(fileName)) return;

  final fields = <Map<String, String>>[];

  // ============================================================
  // 1️⃣ Extract Fields
  // ============================================================
  for (final entry in json.entries) {
    final jsonKey = entry.key;

    var fieldName = snakeToCamel(jsonKey);

    /// Prevent conflict: class User + field user
    if (fieldName == className.toLowerCase()) {
      fieldName = "${fieldName}Data";
    }

    String dartType;
    String defaultValue;

    /// ✅ Nested Object
    if (entry.value is Map) {
      final childClassName = toPascalCase(fieldName);

      generateModel(childClassName, entry.value as Map<String, dynamic>);

      dartType = childClassName;
      defaultValue = "$childClassName.fromJson({})";
    }
    /// ✅ List of Nested Objects
    else if (entry.value is List &&
        entry.value.isNotEmpty &&
        entry.value.first is Map) {
      final childClassName = toPascalCase(fieldName);

      generateModel(childClassName, entry.value.first as Map<String, dynamic>);

      dartType = "List<$childClassName>";
      defaultValue = "const []";
    }
    /// ✅ Primitive Field
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

  // ============================================================
  // 2️⃣ Imports
  // ============================================================
  buffer.writeln("import 'package:equatable/equatable.dart';");

  for (final field in fields) {
    final type = field["dartType"]!;

    if (isCustomModel(type)) {
      final importFile = "${camelToSnake(type)}.dart";
      if (importFile != fileName) {
        buffer.writeln("import '$importFile';");
      }
    }

    if (type.startsWith("List<")) {
      final inner = type.replaceAll("List<", "").replaceAll(">", "");

      if (isCustomModel(inner)) {
        final importFile = "${camelToSnake(inner)}.dart";
        if (importFile != fileName) {
          buffer.writeln("import '$importFile';");
        }
      }
    }
  }

  buffer.writeln("");

  // ============================================================
  // 3️⃣ Class Definition
  // ============================================================
  buffer.writeln("class $className extends Equatable {");

  for (final field in fields) {
    buffer.writeln("  final ${field["dartType"]} ${field["fieldName"]};");
  }

  /// Constructor
  buffer.writeln("\n  const $className({");
  for (final field in fields) {
    buffer.writeln("    required this.${field["fieldName"]},");
  }
  buffer.writeln("  });");

  // ============================================================
  // 4️⃣ fromJson
  // ============================================================
  buffer.writeln(
    "\n  factory $className.fromJson(Map<String, dynamic> json) {",
  );
  buffer.writeln("    return $className(");

  for (final field in fields) {
    final type = field["dartType"]!;
    final key = field["jsonKey"]!;
    final name = field["fieldName"]!;
    final def = field["default"]!;

    if (isCustomModel(type)) {
      buffer.writeln("      $name: $type.fromJson(json['$key'] ?? {}),");
    } else if (type.startsWith("List<")) {
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
    } else {
      buffer.writeln("      $name: json['$key'] as $type? ?? $def,");
    }
  }

  buffer.writeln("    );");
  buffer.writeln("  }");

  // ============================================================
  // 5️⃣ ✅ FINAL FIX: Proper toJson()
  // ============================================================
  buffer.writeln("\n  Map<String, dynamic> toJson() => {");

  for (final field in fields) {
    final type = field["dartType"]!;
    final key = field["jsonKey"]!;
    final name = field["fieldName"]!;

    /// Nested Object → toJson()
    if (isCustomModel(type)) {
      buffer.writeln("        '$key': $name.toJson(),");
    }
    /// List<NestedObject> → map toJson()
    else if (type.startsWith("List<")) {
      final inner = type.replaceAll("List<", "").replaceAll(">", "");

      if (isCustomModel(inner)) {
        buffer.writeln(
          "        '$key': $name.map((e) => e.toJson()).toList(),",
        );
      } else {
        buffer.writeln("        '$key': $name,");
      }
    }
    /// Primitive
    else {
      buffer.writeln("        '$key': $name,");
    }
  }

  buffer.writeln("      };");

  // ============================================================
  // 6️⃣ Equatable Props
  // ============================================================
  buffer.writeln("\n  @override");
  buffer.writeln("  List<Object> get props => [");

  for (final field in fields) {
    buffer.writeln("        ${field["fieldName"]},");
  }

  buffer.writeln("      ];");

  buffer.writeln("}");

  /// Save model
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

String toPascalCase(String name) {
  if (name.isEmpty) return name;
  return name[0].toUpperCase() + name.substring(1);
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
