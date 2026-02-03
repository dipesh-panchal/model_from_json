# Example: Model Generation

This folder demonstrates how to use **model_from_json**.

---

## Input JSON

File:

```

example/json/api-res.json

````

---

## Generate Models

Run:

```bash
dart run model_from_json example/json/api-res.json --name ApiResponse --out example/output
````

---

## Output

Generated models will appear here:

```
example/output/
 ├── api_response.dart
 ├── meta.dart
 ├── user.dart
 ├── accounts.dart
 ├── subscription.dart
 └── features.dart
```

---

## Sample Generated Model

Example output (`api_response.dart`):

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

