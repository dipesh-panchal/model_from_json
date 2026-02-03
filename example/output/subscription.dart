import 'package:equatable/equatable.dart';
import 'features.dart';

class Subscription extends Equatable {
  final String plan;
  final List<Features> features;

  const Subscription({
    required this.plan,
    required this.features,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      plan: json['plan'] as String? ?? '',
      features: (json['features'] as List? ?? []).map((e) => Features.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'plan': plan,
        'features': features.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object> get props => [
        plan,
        features,
      ];
}
