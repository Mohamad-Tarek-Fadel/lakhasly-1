class Transcription {
  final int? id;
  final String title;
  final String content;
  final String createdAt;

  Transcription({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Transcription copyWith({
    int? id,
    String? title,
    String? content,
    String? createdAt,
  }) {
    return Transcription(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt,
    };
  }

  factory Transcription.fromMap(Map<String, dynamic> map) {
    return Transcription(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: map['created_at'],
    );
  }
} 