enum BlockType { translation, image, file }

class Block {
  final String id;
  final String messageId;
  final BlockType type;
  final String content; // for translation: text; for image/file: data or url/name
  final int createdAt;

  Block({
    required this.id,
    required this.messageId,
    required this.type,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'messageId': messageId,
        'type': type.name,
        'content': content,
        'createdAt': createdAt,
      };

  static Block fromJson(Map m) => Block(
        id: m['id'] as String,
        messageId: m['messageId'] as String,
        type: BlockType.values.firstWhere((e) => e.name == m['type']),
        content: m['content'] as String,
        createdAt: (m['createdAt'] as num).toInt(),
      );
}
