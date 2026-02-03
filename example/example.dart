import 'package:model_from_json/model_from_json.dart';

void main() {
  /// ✅ Minimal demonstration of the generator API

  runGenerator(
    jsonPath: 'example/api-res.json',
    rootClassName: 'ApiResponse',
    outputDir: 'example/output',
  );
}
