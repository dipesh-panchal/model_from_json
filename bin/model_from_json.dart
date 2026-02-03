import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  print("🚀 Model From JSON Generator");

  // -----------------------------
  // 1. Validate input arguments
  // -----------------------------
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

  final className = args[nameIndex + 1];

  // -----------------------------
  // 2. Read JSON file
  // -----------------------------
  final file = File(jsonPath);

  if (!file.existsSync()) {
    print("\n❌ File not found: $jsonPath");
    exit(1);
  }

  final jsonString = file.readAsStringSync();

  // -----------------------------
  // 3. Decode JSON
  // -----------------------------
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

  // -----------------------------
  // 4. Generate Dart Model Code
  // -----------------------------
  final code = generateModel(className, jsonMap);

  // -----------------------------
  // 5. Write Output File
  // -----------------------------
  final outputFile = "${camelToSnake(className)}.dart";

  File(outputFile).writeAsStringSync(code);

  print("\n✅ Model generated successfully!");
  print("📄 Output: $outputFile\n");
}

// ============================================================
// MODEL GENERATOR
// ============================================================

String generateModel(String className, Map<String, dynamic> json) {
  final buffer = StringBuffer();

  buffer.writeln("import 'package:equatable/equatable.dart';\n");

  // Convert JSON keys → Dart fields
  final fields = <Map<String, String>>[];

  for (final entry in json.entries) {
    final jsonKey = entry.key;
    final fieldName = snakeToCamel(jsonKey);

    final dartType = inferDartType(entry.value);
    final defaultValue = inferDefaultValue(entry.value);

    fields.add({
      "jsonKey": jsonKey,
      "fieldName": fieldName,
      "dartType": dartType,
      "default": defaultValue,
    });
  }

  // -----------------------------
  // Class Header
  // -----------------------------
  buffer.writeln("class $className extends Equatable {");

  // Fields
  for (final field in fields) {
    buffer.writeln("  final ${field["dartType"]} ${field["fieldName"]};");
  }

  // Constructor
  buffer.writeln("\n  const $className({");
  for (final field in fields) {
    buffer.writeln("    required this.${field["fieldName"]},");
  }

  buffer.writeln("  });");

  // fromJson
  buffer.writeln(
    "\n  factory $className.fromJson(Map<String, dynamic> json) {",
  );
  buffer.writeln("    return $className(");

  for (final field in fields) {
    buffer.writeln(
      "      ${field["fieldName"]}: json['${field["jsonKey"]}'] as ${field["dartType"]}? ?? ${field["default"]},",
    );
  }

  buffer.writeln("    );");
  buffer.writeln("  }");

  // toJson
  buffer.writeln("\n  Map<String, dynamic> toJson() => {");

  for (final field in fields) {
    buffer.writeln("        '${field["jsonKey"]}': ${field["fieldName"]},");
  }

  buffer.writeln("      };");

  // toString
  buffer.writeln("\n  @override");
  buffer.writeln("  String toString() =>");
  buffer.writeln(
    "      '$className(${fields.map((f) => "${f["fieldName"]}: \$${f["fieldName"]}").join(", ")})';",
  );

  // props
  buffer.writeln("\n  @override");
  buffer.writeln("  List<Object> get props => [");

  for (final field in fields) {
    buffer.writeln("        ${field["fieldName"]},");
  }

  buffer.writeln("      ];");

  buffer.writeln("}");

  return buffer.toString();
}

// ============================================================
// HELPERS
// ============================================================

String snakeToCamel(String input) {
  final parts = input.split('_');

  return parts.first +
      parts
          .skip(1)
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join();
}

String camelToSnake(String input) {
  return input
      .replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => '_${match.group(0)!.toLowerCase()}',
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
    if (first is Map) return "List<Map<String, dynamic>>";

    return "List<dynamic>";
  }
  if (value is Map) return "Map<String, dynamic>";
  return "String";
}

String inferDefaultValue(dynamic value) {
  if (value is int) return "0";
  if (value is double) return "0.0";
  if (value is bool) return "false";
  if (value is List) return "const []";
  if (value is Map) return "const {}";
  return "''";
}
