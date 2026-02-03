import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final List<String> roles;

  const User({
    required this.id,
    required this.name,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      roles: json['roles'] as List<String>? ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'roles': roles,
      };

  @override
  List<Object> get props => [
        id,
        name,
        roles,
      ];
}
