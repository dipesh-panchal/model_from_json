import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String name;
  final bool active;
  final double rating;

  const UserModel({
    required this.id,
    required this.name,
    required this.active,
    required this.rating,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      rating: json['rating'] as double? ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'active': active,
        'rating': rating,
      };

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, active: $active, rating: $rating)';

  @override
  List<Object> get props => [
        id,
        name,
        active,
        rating,
      ];
}
