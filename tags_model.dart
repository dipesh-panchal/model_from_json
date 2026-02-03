import 'package:equatable/equatable.dart';

class TagsModel extends Equatable {
  final List<String> tags;
  final List<int> scores;
  final List<bool> flags;

  const TagsModel({
    required this.tags,
    required this.scores,
    required this.flags,
  });

  factory TagsModel.fromJson(Map<String, dynamic> json) {
    return TagsModel(
      tags: json['tags'] as List<String>? ?? const [],
      scores: json['scores'] as List<int>? ?? const [],
      flags: json['flags'] as List<bool>? ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'tags': tags,
        'scores': scores,
        'flags': flags,
      };

  @override
  String toString() =>
      'TagsModel(tags: $tags, scores: $scores, flags: $flags)';

  @override
  List<Object> get props => [
        tags,
        scores,
        flags,
      ];
}
