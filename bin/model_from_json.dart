import 'dart:io';
import 'package:model_from_json/model_from_json.dart';

void main(List<String> args) {
  _printBanner();

  String jsonPath;
  String rootClassName;
  String outputDir = ".";

  // ============================================================
  // ✅ HELP COMMAND
  // ============================================================
  if (args.contains("--help") || args.contains("-h")) {
    _printHelp();
    exit(0);
  }

  // ============================================================
  // ✅ INTERACTIVE MODE
  // ============================================================
  if (args.isEmpty) {
    print("✨ Interactive Mode Enabled\n");

    jsonPath = _ask("Enter JSON file path");
    rootClassName = _ask("Enter root class name (e.g. UserModel)");

    outputDir = _askOptional("Enter output folder", defaultValue: ".");

    print("\n⏳ Generating models...\n");
  }
  // ============================================================
  // ✅ COMMAND MODE
  // ============================================================
  else {
    jsonPath = args[0];

    final nameIndex = args.indexOf("--name");
    if (nameIndex == -1 || nameIndex + 1 >= args.length) {
      _error("Missing required argument: --name ClassName");
    }

    rootClassName = args[nameIndex + 1];

    final outIndex = args.indexOf("--out");
    if (outIndex != -1 && outIndex + 1 < args.length) {
      outputDir = args[outIndex + 1];
    }

    print("📌 Input JSON     : $jsonPath");
    print("🏷  Root Class    : $rootClassName");
    print("📂 Output Folder  : $outputDir");
    print("\n⏳ Generating models...\n");
  }

  // ============================================================
  // ✅ RUN GENERATOR
  // ============================================================
  runGenerator(
    jsonPath: jsonPath,
    rootClassName: rootClassName,
    outputDir: outputDir,
  );
}

// ============================================================
// ✅ CLI HELPERS
// ============================================================

void _printBanner() {
  print("────────────────────────────────────────────");
  print("🚀 Model From JSON Generator v0.1");
  print("────────────────────────────────────────────\n");
}

void _printHelp() {
  print("""
Usage:
  dart run model_from_json <json_path> --name ClassName [--out folder]

Options:
  --name   Root model class name (required)
  --out    Output directory (optional, default=current)
  --help   Show this help message

Examples:
  dart run model_from_json config.json --name ConfigModel
  dart run model_from_json complex.json --name UserModel --out lib/models

Interactive Mode:
  dart run model_from_json
""");
}

String _ask(String label) {
  while (true) {
    stdout.write("$label: ");
    final input = stdin.readLineSync()?.trim() ?? "";

    if (input.isNotEmpty) return input;

    print("❌ Input cannot be empty.\n");
  }
}

String _askOptional(String label, {required String defaultValue}) {
  stdout.write("$label [$defaultValue]: ");
  final input = stdin.readLineSync()?.trim();

  if (input == null || input.isEmpty) return defaultValue;

  return input;
}

Never _error(String message) {
  print("\n❌ ERROR: $message\n");
  print("Run with --help to see usage.\n");
  exit(1);
}
