import 'package:equatable/equatable.dart';
import 'meta.dart';
import 'user.dart';
import 'accounts.dart';
import 'subscription.dart';

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
      accounts: (json['accounts'] as List? ?? []).map((e) => Accounts.fromJson(e)).toList(),
      subscription: Subscription.fromJson(json['subscription'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'meta': meta.toJson(),
        'user': user.toJson(),
        'accounts': accounts.map((e) => e.toJson()).toList(),
        'subscription': subscription.toJson(),
      };

  @override
  List<Object> get props => [
        meta,
        user,
        accounts,
        subscription,
      ];
}
