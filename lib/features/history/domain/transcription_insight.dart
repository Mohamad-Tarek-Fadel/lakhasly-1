import '../../common/domain/insight_type.dart';

class TranscriptionInsight {
  final int? id;
  final int transcriptionId;
  final InsightType type;
  final String content;
  final DateTime createdAt;
  final int? rating; // 1-5 rating from user

  TranscriptionInsight({
    this.id,
    required this.transcriptionId,
    required this.type,
    required this.content,
    required this.createdAt,
    this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transcription_id': transcriptionId,
      'type': type.index,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'rating': rating,
    };
  }

  factory TranscriptionInsight.fromMap(Map<String, dynamic> map) {
    return TranscriptionInsight(
      id: map['id'],
      transcriptionId: map['transcription_id'],
      type: InsightType.values[map['type']],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      rating: map['rating'],
    );
  }

  TranscriptionInsight copyWith({
    int? id,
    int? transcriptionId,
    InsightType? type,
    String? content,
    DateTime? createdAt,
    int? rating,
  }) {
    return TranscriptionInsight(
      id: id ?? this.id,
      transcriptionId: transcriptionId ?? this.transcriptionId,
      type: type ?? this.type,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
    );
  }
} 