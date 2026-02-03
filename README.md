# Model From JSON 🚀

[![pub package](https://img.shields.io/pub/v/model_from_json.svg)](https://pub.dev/packages/model_from_json)
[![likes](https://img.shields.io/pub/likes/model_from_json)](https://pub.dev/packages/model_from_json/score)
[![popularity](https://img.shields.io/pub/popularity/model_from_json)](https://pub.dev/packages/model_from_json/score)
[![pub points](https://img.shields.io/pub/points/model_from_json)](https://pub.dev/packages/model_from_json/score)

A **zero-setup Dart CLI tool** that generates clean, Equatable-ready Dart model
classes directly from JSON.

✅ No annotations  
✅ No `build_runner`  
✅ No `.g.dart` files  
✅ Just instant model generation  

⚡ Generates models in **under 1 second** for most API JSON files — no codegen pipeline needed.

---

## ✨ Why Model From JSON?

Most Flutter model generators require:

- Annotations (`@JsonSerializable`)
- `build_runner` commands
- Generated `.g.dart` part files
- Extra boilerplate setup

**model_from_json** is different:

✅ Works instantly  
✅ Outputs plain Dart files immediately  
✅ Perfect for rapid development and API prototyping  

---

## 🎬 Demo

Generate models instantly:

```bash
model_from_json complex.json --name ApiResponse --out lib/models
````

Output:

```
✅ Done! Generated 6 model files:

📄 api_response.dart
📄 meta.dart
📄 user.dart
📄 accounts.dart
📄 subscription.dart
📄 features.dart
```

---

## ✅ Features

* ✅ Generate Dart model classes automatically from JSON
* ✅ Supports nested objects (`profile`, `subscription`, etc.)
* ✅ Supports lists of nested objects (`accounts`, `features`, etc.)
* ✅ Generates complete boilerplate:

  * `fromJson()`
  * `toJson()` (with nested serialization)
  * Equatable `props`
* ✅ Generates multiple `.dart` files recursively
* ✅ Supports both:

  * Command mode
  * Interactive mode
* ✅ Optional output folder support (`--out`)

---

## 📦 Installation

Activate globally:

```bash
dart pub global activate model_from_json
```

Run anywhere:

```bash
model_from_json <json_path> --name ClassName
```

---

## 🚀 Usage

---

### ✅ Command Mode

Generate models into the current directory:

```bash
model_from_json complex.json --name ApiResponse
```

Generate models into a folder:

```bash
model_from_json complex.json --name ApiResponse --out lib/models
```

---

### ✅ Interactive Mode

Run without arguments:

```bash
model_from_json
```

You will be guided step-by-step:

```
Enter JSON file path: ultra.json
Enter root class name: ApiResponse
Enter output folder [.] : lib/models
```

---

## 🧾 Example Input

### `complex.json`

```json
{
  "meta": {
    "request_id": "REQ-123",
    "success": true
  },
  "user": {
    "id": 101,
    "name": "Dipesh Panchal",
    "roles": ["trader", "developer"]
  },
  "accounts": [
    {
      "broker": "zerodha",
      "balance": 250000.75
    }
  ],
  "subscription": {
    "plan": "pro",
    "features": [
      {
        "name": "nested_models",
        "enabled": true
      }
    ]
  }
}
```

---

## ✅ Example Output

### `api_response.dart`

```dart
class ApiResponse extends Equatable {
  final Meta meta;
  final User user;
  final List<Accounts> accounts;
  final Subscription subscription;

  const ApiResponse({
    required this.meta,
    required this.user,
    required this.accounts,
    required this.subscription,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      meta: Meta.fromJson(json['meta'] ?? {}),
      user: User.fromJson(json['user'] ?? {}),
      accounts: (json['accounts'] as List? ?? [])
          .map((e) => Accounts.fromJson(e))
          .toList(),
      subscription: Subscription.fromJson(json['subscription'] ?? {}),
    );
  }
}
```

---

## 📂 Output Structure

Generated folder example:

```
lib/models/
 ├── api_response.dart
 ├── meta.dart
 ├── user.dart
 ├── accounts.dart
 ├── subscription.dart
 └── features.dart
```

---

## ⚙️ CLI Options

| Option   | Description                 |
| -------- | --------------------------- |
| `--name` | Root class name (required)  |
| `--out`  | Output folder (optional)    |
| `--help` | Show CLI usage instructions |

---

## ✅ Roadmap

Planned future improvements:

* Nullable type inference (`String? phone`)
* Dictionary/Map field support (`Map<String,dynamic> metadata`)
* Smarter naming (`daily_pnl → DailyPnl`)
* Barrel export generation (`models.dart`)
* Optional Freezed/json_serializable generation mode

---

## 🤝 Contributing

Pull requests and improvements are welcome!

```bash
git clone https://github.com/yourusername/model_from_json.git
cd model_from_json
dart pub get
dart run
```

---

## 📜 License

MIT License © 2026 Dipesh Panchal

---

## ⭐ Support

If you find this tool useful, consider starring the repo and sharing it with the Flutter community 🚀
