import 'package:equatable/equatable.dart';

class Features extends Equatable {
  final String name;
  final bool enabled;

  const Features({
    required this.name,
    required this.enabled,
  });

  factory Features.fromJson(Map<String, dynamic> json) {
    return Features(
      name: json['name'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'enabled': enabled,
      };

  @override
  List<Object> get props => [
        name,
        enabled,
      ];
}
