import 'package:hive/hive.dart';

part 'message_block.g.dart';

// 消息块类型枚举
@HiveType(typeId: 10)
enum MessageBlockType {
  @HiveField(0)
  text,
  @HiveField(1)
  code,
  @HiveField(2)
  image,
  @HiveField(3)
  file,
  @HiveField(4)
  tool,
  @HiveField(5)
  translation,
  @HiveField(6)
  citation,
  @HiveField(7)
  thinking,
}

// 消息块状态枚举
@HiveType(typeId: 11)
enum MessageBlockStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  loading,
  @HiveField(2)
  completed,
  @HiveField(3)
  error,
}

@HiveType(typeId: 4)
class MessageBlockModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String messageId;
  
  @HiveField(2)
  MessageBlockType type;
  
  @HiveField(3)
  MessageBlockStatus status;
  
  @HiveField(4)
  String? model; // JSON string
  
  @HiveField(5)
  String? metadata; // JSON string
  
  @HiveField(6)
  String? error; // JSON string
  
  // 内容字段
  @HiveField(7)
  String? content;
  
  @HiveField(8)
  String? language; // 用于代码块
  
  @HiveField(9)
  String? url; // 用于图片块
  
  @HiveField(10)
  String? file; // JSON string，用于文件块
  
  // 工具块特定字段
  @HiveField(11)
  String? toolId;
  
  @HiveField(12)
  String? toolName;
  
  @HiveField(13)
  String? arguments; // JSON string
  
  // 翻译块特定字段
  @HiveField(14)
  String? sourceBlockId;
  
  @HiveField(15)
  String? sourceLanguage;
  
  @HiveField(16)
  String? targetLanguage;
  
  // 引用块特定字段
  @HiveField(17)
  String? response; // JSON string
  
  @HiveField(18)
  String? knowledge; // JSON string
  
  // 思考块特定字段
  @HiveField(19)
  int? thinkingMillsec;
  
  // 主文本块特定字段
  @HiveField(20)
  String? knowledgeBaseIds; // JSON array string
  
  @HiveField(21)
  String? citationReferences; // JSON string
  
  @HiveField(22)
  int createdAt;
  
  @HiveField(23)
  int updatedAt;

  MessageBlockModel({
    required this.id,
    required this.messageId,
    required this.type,
    required this.status,
    this.model,
    this.metadata,
    this.error,
    this.content,
    this.language,
    this.url,
    this.file,
    this.toolId,
    this.toolName,
    this.arguments,
    this.sourceBlockId,
    this.sourceLanguage,
    this.targetLanguage,
    this.response,
    this.knowledge,
    this.thinkingMillsec,
    this.knowledgeBaseIds,
    this.citationReferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageBlockModel.fromJson(Map<String, dynamic> json) {
    return MessageBlockModel(
      id: json['id'] as String,
      messageId: json['message_id'] as String,
      type: _parseBlockType(json['type'] as String),
      status: _parseBlockStatus(json['status'] as String),
      model: json['model'] as String?,
      metadata: json['metadata'] as String?,
      error: json['error'] as String?,
      content: json['content'] as String?,
      language: json['language'] as String?,
      url: json['url'] as String?,
      file: json['file'] as String?,
      toolId: json['tool_id'] as String?,
      toolName: json['tool_name'] as String?,
      arguments: json['arguments'] as String?,
      sourceBlockId: json['source_block_id'] as String?,
      sourceLanguage: json['source_language'] as String?,
      targetLanguage: json['target_language'] as String?,
      response: json['response'] as String?,
      knowledge: json['knowledge'] as String?,
      thinkingMillsec: json['thinking_millsec'] as int?,
      knowledgeBaseIds: json['knowledge_base_ids'] as String?,
      citationReferences: json['citation_references'] as String?,
      createdAt: json['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: json['updated_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message_id': messageId,
      'type': type.name,
      'status': status.name,
      'model': model,
      'metadata': metadata,
      'error': error,
      'content': content,
      'language': language,
      'url': url,
      'file': file,
      'tool_id': toolId,
      'tool_name': toolName,
      'arguments': arguments,
      'source_block_id': sourceBlockId,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'response': response,
      'knowledge': knowledge,
      'thinking_millsec': thinkingMillsec,
      'knowledge_base_ids': knowledgeBaseIds,
      'citation_references': citationReferences,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static MessageBlockType _parseBlockType(String value) {
    switch (value) {
      case 'text':
        return MessageBlockType.text;
      case 'code':
        return MessageBlockType.code;
      case 'image':
        return MessageBlockType.image;
      case 'file':
        return MessageBlockType.file;
      case 'tool':
        return MessageBlockType.tool;
      case 'translation':
        return MessageBlockType.translation;
      case 'citation':
        return MessageBlockType.citation;
      case 'thinking':
        return MessageBlockType.thinking;
      default:
        return MessageBlockType.text;
    }
  }

  static MessageBlockStatus _parseBlockStatus(String value) {
    switch (value) {
      case 'pending':
        return MessageBlockStatus.pending;
      case 'loading':
        return MessageBlockStatus.loading;
      case 'completed':
        return MessageBlockStatus.completed;
      case 'error':
        return MessageBlockStatus.error;
      default:
        return MessageBlockStatus.pending;
    }
  }

  MessageBlockModel copyWith({
    String? id,
    String? messageId,
    MessageBlockType? type,
    MessageBlockStatus? status,
    String? model,
    String? metadata,
    String? error,
    String? content,
    String? language,
    String? url,
    String? file,
    String? toolId,
    String? toolName,
    String? arguments,
    String? sourceBlockId,
    String? sourceLanguage,
    String? targetLanguage,
    String? response,
    String? knowledge,
    int? thinkingMillsec,
    String? knowledgeBaseIds,
    String? citationReferences,
    int? createdAt,
    int? updatedAt,
  }) {
    return MessageBlockModel(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      type: type ?? this.type,
      status: status ?? this.status,
      model: model ?? this.model,
      metadata: metadata ?? this.metadata,
      error: error ?? this.error,
      content: content ?? this.content,
      language: language ?? this.language,
      url: url ?? this.url,
      file: file ?? this.file,
      toolId: toolId ?? this.toolId,
      toolName: toolName ?? this.toolName,
      arguments: arguments ?? this.arguments,
      sourceBlockId: sourceBlockId ?? this.sourceBlockId,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      response: response ?? this.response,
      knowledge: knowledge ?? this.knowledge,
      thinkingMillsec: thinkingMillsec ?? this.thinkingMillsec,
      knowledgeBaseIds: knowledgeBaseIds ?? this.knowledgeBaseIds,
      citationReferences: citationReferences ?? this.citationReferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}