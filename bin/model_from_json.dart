import 'dart:convert';
import 'dart:io';

/// ============================================================
/// ✅ MODEL FROM JSON GENERATOR
/// ============================================================
///
/// This tool generates Dart Equatable model classes automatically
/// from a JSON file.
///
/// Features Supported:
/// ------------------------------------------------------------
/// ✅ Primitive Types: String, int, double, bool
/// ✅ List Types: List<String>, List<int>, List<bool>, etc.
/// ✅ Nested Objects: Generates separate model files recursively
/// ✅ List of Nested Objects: Generates List<ChildModel>
/// ✅ Multi-file Output: Writes all models into separate .dart files
///
/// Example:
/// ------------------------------------------------------------
/// Input JSON:
///
/// {
///   "id": 1,
///   "profile": { "name": "Dipesh" },
///   "addresses": [ { "city": "Mumbai" } ]
/// }
///
/// Output Files:
/// ------------------------------------------------------------
/// user_model.dart
/// profile.dart
/// addresses.dart
///
/// ============================================================

/// ✅ Global registry that stores all generated model code
/// Key   = filename (snake_case)
/// Value = Dart model source code
final Map<String, String> generatedModels = {};

void main(List<String> args) {
  print("🚀 Model From JSON Generator");

  // ============================================================
  // 1️⃣ Validate CLI Arguments
  // ============================================================
  if (args.isEmpty) {
    print("\nUsage:");
    print("  dart run model_from_json <json_path> --name ClassName");
    exit(1);
  }

  final jsonPath = args[0];

  // Find --name argument
  final nameIndex = args.indexOf("--name");
  if (nameIndex == -1 || nameIndex + 1 >= args.length) {
    print("\n❌ Missing required argument: --name ClassName");
    exit(1);
  }

  final rootClassName = args[nameIndex + 1];

  // ============================================================
  // 2️⃣ Read JSON File
  // ============================================================
  final file = File(jsonPath);

  if (!file.existsSync()) {
    print("\n❌ File not found: $jsonPath");
    exit(1);
  }

  final jsonString = file.readAsStringSync();

  // ============================================================
  // 3️⃣ Decode JSON
  // ============================================================
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

  // ============================================================
  // 4️⃣ Generate Models Recursively
  // ============================================================
  generateModel(rootClassName, jsonMap);

  // ============================================================
  // 5️⃣ Write Output Files
  // ============================================================
  print("\n✅ Models generated:\n");

  for (final entry in generatedModels.entries) {
    File(entry.key).writeAsStringSync(entry.value);
    print("📄 ${entry.key}");
  }

  print("\n🎉 Done!\n");
}

/// ============================================================
/// ✅ Recursive Model Generator
/// ============================================================
///
/// - Generates Dart model class for given JSON Map
/// - Recursively generates nested objects
/// - Stores all output into `generatedModels` map
///
/// ============================================================
void generateModel(String className, Map<String, dynamic> json) {
  final buffer = StringBuffer();

  /// Convert class name → filename
  final fileName = "${camelToSnake(className)}.dart";

  /// Prevent duplicate generation
  if (generatedModels.containsKey(fileName)) return;

  // ============================================================
  // 1️⃣ Extract Fields
  // ============================================================
  final fields = <Map<String, String>>[];

  for (final entry in json.entries) {
    final jsonKey = entry.key;

    /// Convert JSON key → Dart field name
    final fieldName = snakeToCamel(jsonKey);

    String dartType;
    String defaultValue;

    // ✅ Case 1: Nested Object → Generate separate model
    if (entry.value is Map) {
      final childClassName =
          fieldName[0].toUpperCase() + fieldName.substring(1);

      generateModel(childClassName, entry.value as Map<String, dynamic>);

      dartType = childClassName;
      defaultValue = "$childClassName.fromJson({})";
    }
    // ✅ Case 2: List of Nested Objects → List<ChildModel>
    else if (entry.value is List &&
        entry.value.isNotEmpty &&
        entry.value.first is Map) {
      /// Key name preserved exactly:
      /// addresses → Addresses (NOT Address)
      final childClassName =
          fieldName[0].toUpperCase() + fieldName.substring(1);

      generateModel(childClassName, entry.value.first as Map<String, dynamic>);

      dartType = "List<$childClassName>";
      defaultValue = "const []";
    }
    // ✅ Case 3: Primitive or List of Primitives
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

    // ✅ Import nested object type
    if (isCustomModel(type)) {
      buffer.writeln("import '${camelToSnake(type)}.dart';");
    }

    // ✅ Import List<NestedObject>
    if (type.startsWith("List<")) {
      final innerType = type.replaceAll("List<", "").replaceAll(">", "");

      if (isCustomModel(innerType)) {
        buffer.writeln("import '${camelToSnake(innerType)}.dart';");
      }
    }
  }

  buffer.writeln("");

  // ============================================================
  // 3️⃣ Class Definition
  // ============================================================
  buffer.writeln("class $className extends Equatable {");

  /// Fields
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
  // 4️⃣ fromJson Constructor
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

    // ✅ Nested object
    if (isCustomModel(type)) {
      buffer.writeln("      $name: $type.fromJson(json['$key'] ?? {}),");
    }
    // ✅ List<NestedObject>
    else if (type.startsWith("List<")) {
      final innerType = type.replaceAll("List<", "").replaceAll(">", "");

      if (isCustomModel(innerType)) {
        buffer.writeln(
          "      $name: (json['$key'] as List? ?? [])"
          ".map((e) => $innerType.fromJson(e))"
          ".toList(),",
        );
      } else {
        buffer.writeln("      $name: json['$key'] as $type? ?? $def,");
      }
    }
    // ✅ Primitive
    else {
      buffer.writeln("      $name: json['$key'] as $type? ?? $def,");
    }
  }

  buffer.writeln("    );");
  buffer.writeln("  }");

  // ============================================================
  // 5️⃣ toJson Method
  // ============================================================
  buffer.writeln("\n  Map<String, dynamic> toJson() => {");

  for (final field in fields) {
    buffer.writeln("        '${field["jsonKey"]}': ${field["fieldName"]},");
  }

  buffer.writeln("      };");

  // ============================================================
  // 6️⃣ Equatable Overrides
  // ============================================================
  buffer.writeln("\n  @override");
  buffer.writeln(
    "  String toString() => '$className(${fields.map((f) => "${f["fieldName"]}: \$${f["fieldName"]}").join(", ")})';",
  );

  buffer.writeln("\n  @override");
  buffer.writeln("  List<Object> get props => [");

  for (final field in fields) {
    buffer.writeln("        ${field["fieldName"]},");
  }

  buffer.writeln("      ];");

  buffer.writeln("}");

  // ✅ Store generated model file
  generatedModels[fileName] = buffer.toString();
}

// ============================================================
// HELPER FUNCTIONS
// ============================================================

/// Returns true if this is a user-defined generated model type
bool isCustomModel(String type) {
  return type[0].toUpperCase() == type[0] &&
      type != "String" &&
      type != "int" &&
      type != "double" &&
      type != "bool" &&
      !type.startsWith("List");
}

/// Convert snake_case → camelCase
String snakeToCamel(String input) {
  final parts = input.split('_');

  return parts.first +
      parts.skip(1).map((w) => w[0].toUpperCase() + w.substring(1)).join();
}

/// Convert CamelCase → snake_case filename
String camelToSnake(String input) {
  return input
      .replaceAllMapped(
        RegExp(r'[A-Z]'),
        (m) => '_${m.group(0)!.toLowerCase()}',
      )
      .replaceFirst('_', '');
}

/// Infer Dart type from JSON value
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

/// Infer safe default fallback
String inferDefaultValue(dynamic value) {
  if (value is int) return "0";
  if (value is double) return "0.0";
  if (value is bool) return "false";
  if (value is List) return "const []";

  return "''";
}
