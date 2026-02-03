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
  final outputFile = "${className.toLowerCase()}.dart";

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
  final fields = <String, String>{};

  for (final entry in json.entries) {
    final fieldName = snakeToCamel(entry.key);
    fields[entry.key] = fieldName;
  }

  // -----------------------------
  // Class Header
  // -----------------------------
  buffer.writeln("class $className extends Equatable {");

  // Fields
  for (final field in fields.values) {
    buffer.writeln("  final String $field;");
  }

  // Constructor
  buffer.writeln("\n  const $className({");
  for (final field in fields.values) {
    buffer.writeln("    required this.$field,");
  }
  buffer.writeln("  });");

  // fromJson
  buffer.writeln(
    "\n  factory $className.fromJson(Map<String, dynamic> json) {",
  );
  buffer.writeln("    return $className(");

  for (final entry in fields.entries) {
    buffer.writeln(
      "      ${entry.value}: json['${entry.key}'] as String? ?? '',",
    );
  }

  buffer.writeln("    );");
  buffer.writeln("  }");

  // toJson
  buffer.writeln("\n  Map<String, dynamic> toJson() => {");

  for (final entry in fields.entries) {
    buffer.writeln("        '${entry.key}': ${entry.value},");
  }

  buffer.writeln("      };");

  // toString
  buffer.writeln("\n  @override");
  buffer.writeln("  String toString() =>");
  buffer.writeln(
    "      '$className(${fields.values.map((f) => "$f: \$$f").join(", ")})';",
  );

  // props
  buffer.writeln("\n  @override");
  buffer.writeln("  List<Object> get props => [");

  for (final field in fields.values) {
    buffer.writeln("        $field,");
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
