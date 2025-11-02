import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 3)
class MessageModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String role; // 'user', 'assistant', 'system'
  
  @HiveField(2)
  String assistantId;
  
  @HiveField(3)
  String topicId;
  
  @HiveField(4)
  String status; // 'pending', 'sending', 'completed', 'error'
  
  @HiveField(5)
  String? modelId;
  
  @HiveField(6)
  String? model;
  
  @HiveField(7)
  String? type;
  
  @HiveField(8)
  bool useful;
  
  @HiveField(9)
  String? askId;
  
  @HiveField(10)
  String? mentions; // JSON array string
  
  @HiveField(11)
  String? usage; // JSON string
  
  @HiveField(12)
  String? metrics; // JSON string
  
  @HiveField(13)
  String? multiModelMessageStyle;
  
  @HiveField(14)
  bool foldSelected;
  
  @HiveField(15)
  int createdAt;
  
  @HiveField(16)
  int updatedAt;

  MessageModel({
    required this.id,
    required this.role,
    required this.assistantId,
    required this.topicId,
    required this.status,
    this.modelId,
    this.model,
    this.type,
    this.useful = true,
    this.askId,
    this.mentions,
    this.usage,
    this.metrics,
    this.multiModelMessageStyle,
    this.foldSelected = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      role: json['role'] as String,
      assistantId: json['assistant_id'] as String,
      topicId: json['topic_id'] as String,
      status: json['status'] as String,
      modelId: json['model_id'] as String?,
      model: json['model'] as String?,
      type: json['type'] as String?,
      useful: json['useful'] as bool? ?? true,
      askId: json['ask_id'] as String?,
      mentions: json['mentions'] as String?,
      usage: json['usage'] as String?,
      metrics: json['metrics'] as String?,
      multiModelMessageStyle: json['multi_model_message_style'] as String?,
      foldSelected: json['fold_selected'] as bool? ?? false,
      createdAt: json['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: json['updated_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'assistant_id': assistantId,
      'topic_id': topicId,
      'status': status,
      'model_id': modelId,
      'model': model,
      'type': type,
      'useful': useful,
      'ask_id': askId,
      'mentions': mentions,
      'usage': usage,
      'metrics': metrics,
      'multi_model_message_style': multiModelMessageStyle,
      'fold_selected': foldSelected,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  MessageModel copyWith({
    String? id,
    String? role,
    String? assistantId,
    String? topicId,
    String? status,
    String? modelId,
    String? model,
    String? type,
    bool? useful,
    String? askId,
    String? mentions,
    String? usage,
    String? metrics,
    String? multiModelMessageStyle,
    bool? foldSelected,
    int? createdAt,
    int? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      assistantId: assistantId ?? this.assistantId,
      topicId: topicId ?? this.topicId,
      status: status ?? this.status,
      modelId: modelId ?? this.modelId,
      model: model ?? this.model,
      type: type ?? this.type,
      useful: useful ?? this.useful,
      askId: askId ?? this.askId,
      mentions: mentions ?? this.mentions,
      usage: usage ?? this.usage,
      metrics: metrics ?? this.metrics,
      multiModelMessageStyle: multiModelMessageStyle ?? this.multiModelMessageStyle,
      foldSelected: foldSelected ?? this.foldSelected,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}