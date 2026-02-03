import 'package:equatable/equatable.dart';

class Meta extends Equatable {
  final String requestId;
  final bool success;

  const Meta({
    required this.requestId,
    required this.success,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      requestId: json['request_id'] as String? ?? '',
      success: json['success'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'request_id': requestId,
        'success': success,
      };

  @override
  List<Object> get props => [
        requestId,
        success,
      ];
}
