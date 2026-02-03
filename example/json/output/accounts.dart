import 'package:equatable/equatable.dart';

class Accounts extends Equatable {
  final String broker;
  final double balance;

  const Accounts({
    required this.broker,
    required this.balance,
  });

  factory Accounts.fromJson(Map<String, dynamic> json) {
    return Accounts(
      broker: json['broker'] as String? ?? '',
      balance: json['balance'] as double? ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'broker': broker,
        'balance': balance,
      };

  @override
  List<Object> get props => [
        broker,
        balance,
      ];
}
