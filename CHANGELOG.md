## 1.0.2 — Initial Release (2026-02-03)

🎉 First public release of **model_from_json**.

### Features

- ✅ Generate Dart model classes automatically from JSON files
- ✅ Supports primitive field inference:
  - `String`, `int`, `double`, `bool`
- ✅ Supports lists of primitives:
  - `List<String>`, `List<int>`, `List<bool>`, etc.
- ✅ Recursive nested model generation:
  - Generates child models automatically for nested objects
- ✅ Supports lists of nested objects:
  - Generates `List<ChildModel>` correctly
- ✅ Generates complete model boilerplate:
  - `fromJson()`
  - `toJson()` (including nested `.toJson()` support)
  - Equatable `props` override
- ✅ Multi-file output support:
  - Outputs one Dart file per model
- ✅ Optional output folder support with `--out`
- ✅ Interactive CLI mode when run with no arguments
- ✅ Prettified CLI UX:
  - Banner, prompts, summaries