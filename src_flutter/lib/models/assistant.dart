import 'package:hive/hive.dart';

part 'assistant.g.dart';

@HiveType(typeId: 2)
class AssistantModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String prompt;
  
  @HiveField(3)
  String type; // 'built_in', 'custom'
  
  @HiveField(4)
  String? emoji;
  
  @HiveField(5)
  String? description;
  
  @HiveField(6)
  String? model;
  
  @HiveField(7)
  String? defaultModel;
  
  @HiveField(8)
  String? settings; // JSON string
  
  @HiveField(9)
  bool enableWebSearch;
  
  @HiveField(10)
  bool enableGenerateImage;
  
  @HiveField(11)
  String? mcpServers; // JSON array string
  
  @HiveField(12)
  String? knowledgeRecognition;
  
  @HiveField(13)
  String? tags; // JSON array string
  
  @HiveField(14)
  String? group;
  
  @HiveField(15)
  String? websearchProviderId;
  
  @HiveField(16)
  int createdAt;
  
  @HiveField(17)
  int updatedAt;

  AssistantModel({
    required this.id,
    required this.name,
    required this.prompt,
    this.type = 'built_in',
    this.emoji,
    this.description,
    this.model,
    this.defaultModel,
    this.settings,
    this.enableWebSearch = false,
    this.enableGenerateImage = false,
    this.mcpServers,
    this.knowledgeRecognition,
    this.tags,
    this.group,
    this.websearchProviderId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssistantModel.fromJson(Map<String, dynamic> json) {
    return AssistantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      prompt: json['prompt'] as String,
      type: json['type'] as String? ?? 'built_in',
      emoji: json['emoji'] as String?,
      description: json['description'] as String?,
      model: json['model'] as String?,
      defaultModel: json['default_model'] as String?,
      settings: json['settings'] as String?,
      enableWebSearch: json['enable_web_search'] as bool? ?? false,
      enableGenerateImage: json['enable_generate_image'] as bool? ?? false,
      mcpServers: json['mcp_servers'] as String?,
      knowledgeRecognition: json['knowledge_recognition'] as String?,
      tags: json['tags'] as String?,
      group: json['group'] as String?,
      websearchProviderId: json['websearch_provider_id'] as String?,
      createdAt: json['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: json['updated_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'prompt': prompt,
      'type': type,
      'emoji': emoji,
      'description': description,
      'model': model,
      'default_model': defaultModel,
      'settings': settings,
      'enable_web_search': enableWebSearch,
      'enable_generate_image': enableGenerateImage,
      'mcp_servers': mcpServers,
      'knowledge_recognition': knowledgeRecognition,
      'tags': tags,
      'group': group,
      'websearch_provider_id': websearchProviderId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  AssistantModel copyWith({
    String? id,
    String? name,
    String? prompt,
    String? type,
    String? emoji,
    String? description,
    String? model,
    String? defaultModel,
    String? settings,
    bool? enableWebSearch,
    bool? enableGenerateImage,
    String? mcpServers,
    String? knowledgeRecognition,
    String? tags,
    String? group,
    String? websearchProviderId,
    int? createdAt,
    int? updatedAt,
  }) {
    return AssistantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      prompt: prompt ?? this.prompt,
      type: type ?? this.type,
      emoji: emoji ?? this.emoji,
      description: description ?? this.description,
      model: model ?? this.model,
      defaultModel: defaultModel ?? this.defaultModel,
      settings: settings ?? this.settings,
      enableWebSearch: enableWebSearch ?? this.enableWebSearch,
      enableGenerateImage: enableGenerateImage ?? this.enableGenerateImage,
      mcpServers: mcpServers ?? this.mcpServers,
      knowledgeRecognition: knowledgeRecognition ?? this.knowledgeRecognition,
      tags: tags ?? this.tags,
      group: group ?? this.group,
      websearchProviderId: websearchProviderId ?? this.websearchProviderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}