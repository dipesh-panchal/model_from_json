# Model From JSON 🚀

A lightweight Dart CLI tool that generates **Equatable-ready Dart model classes**
directly from a JSON file.

Designed for Flutter developers who want:

✅ Fast model generation  
✅ Nested model support  
✅ List of nested objects  
✅ `fromJson()` + `toJson()` built-in  
✅ Clean multi-file output  
✅ Interactive CLI mode  

---

## ✨ Features

- ✅ Generates Dart model classes automatically from JSON
- ✅ Supports nested objects (`profile`, `subscription`, etc.)
- ✅ Supports lists of nested objects (`accounts`, `features`, etc.)
- ✅ Produces clean, Equatable-compatible models
- ✅ Generates multiple `.dart` files recursively
- ✅ Supports both:
  - Command mode
  - Interactive mode
- ✅ Optional output folder support (`--out`)

---

## 📦 Installation

### Activate globally (recommended)

```bash
dart pub global activate model_from_json
````

Now you can run:

```bash
model_from_json <json_path> --name ClassName
```

---

## 🚀 Usage

---

### ✅ Command Mode

Generate models from JSON in the current folder:

```bash
model_from_json complex.json --name ApiResponse
```

Generate models into a custom folder:

```bash
model_from_json complex.json --name ApiResponse --out lib/models
```

---

### ✅ Interactive Mode

Run without arguments:

```bash
model_from_json
```

It will prompt you:

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
  "user": {
    "id": 1,
    "name": "Dipesh"
  },
  "accounts": [
    {
      "broker": "zerodha",
      "balance": 250000
    }
  ]
}
```

---

## ✅ Output Generated

### `api_response.dart`

```dart
class ApiResponse extends Equatable {
  final User user;
  final List<Accounts> accounts;

  const ApiResponse({
    required this.user,
    required this.accounts,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      user: User.fromJson(json['user'] ?? {}),
      accounts: (json['accounts'] as List? ?? [])
          .map((e) => Accounts.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'accounts': accounts.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [user, accounts];
}
```

---

## 📂 Output Structure

Example generated folder:

```
lib/models/
 ├── api_response.dart
 ├── user.dart
 ├── accounts.dart
 └── broker_settings.dart
```

---

## ⚙️ CLI Options

| Option   | Description                |
| -------- | -------------------------- |
| `--name` | Root class name (required) |
| `--out`  | Output folder (optional)   |
| `--help` | Show usage help            |

---

## ✅ Roadmap (Upcoming)

Planned improvements:

* Nullable type inference (`String? phone`)
* Dictionary/Map field support (`Map<String,dynamic> metadata`)
* Better naming rules (`daily_pnl → DailyPnl`)
* Barrel export generation (`models.dart`)
* Pub.dev v1.0 stable release

---

## 🤝 Contributing

Pull requests are welcome!

To contribute:

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

If you find this tool useful, consider starring the repo and sharing it with Flutter developers!

