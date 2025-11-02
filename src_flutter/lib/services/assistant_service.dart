import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../data/boxes.dart';
import '../models/assistant.dart';

class AssistantService {
  static final AssistantService _instance = AssistantService._internal();
  factory AssistantService() => _instance;
  AssistantService._internal();

  final _uuid = const Uuid();

  // 获取所有助手
  List<AssistantModel> getAllAssistants() {
    final box = HiveBoxes.getAssistantsBox();
    return box.values.toList();
  }

  // 根据ID获取助手
  AssistantModel? getAssistantById(String id) {
    final box = HiveBoxes.getAssistantsBox();
    return box.get(id);
  }

  // 创建新助手
  Future<AssistantModel> createAssistant({
    required String name,
    required String prompt,
    String type = 'custom',
    String? emoji,
    String? description,
    String? model,
    String? defaultModel,
    String? settings,
    bool enableWebSearch = false,
    bool enableGenerateImage = false,
    String? mcpServers,
    String? knowledgeRecognition,
    String? tags,
    String? group,
    String? websearchProviderId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final assistant = AssistantModel(
      id: _uuid.v4(),
      name: name,
      prompt: prompt,
      type: type,
      emoji: emoji,
      description: description,
      model: model,
      defaultModel: defaultModel,
      settings: settings,
      enableWebSearch: enableWebSearch,
      enableGenerateImage: enableGenerateImage,
      mcpServers: mcpServers,
      knowledgeRecognition: knowledgeRecognition,
      tags: tags,
      group: group,
      websearchProviderId: websearchProviderId,
      createdAt: now,
      updatedAt: now,
    );

    final box = HiveBoxes.getAssistantsBox();
    await box.put(assistant.id, assistant);
    return assistant;
  }

  // 更新助手
  Future<void> updateAssistant(String id, {
    String? name,
    String? prompt,
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
  }) async {
    final box = HiveBoxes.getAssistantsBox();
    final assistant = box.get(id);
    if (assistant != null) {
      final updatedAssistant = assistant.copyWith(
        name: name,
        prompt: prompt,
        emoji: emoji,
        description: description,
        model: model,
        defaultModel: defaultModel,
        settings: settings,
        enableWebSearch: enableWebSearch,
        enableGenerateImage: enableGenerateImage,
        mcpServers: mcpServers,
        knowledgeRecognition: knowledgeRecognition,
        tags: tags,
        group: group,
        websearchProviderId: websearchProviderId,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await box.put(id, updatedAssistant);
    }
  }

  // 删除助手
  Future<void> deleteAssistant(String id) async {
    final box = HiveBoxes.getAssistantsBox();
    await box.delete(id);
  }

  // 获取内置助手
  List<AssistantModel> getBuiltInAssistants() {
    final assistants = getAllAssistants();
    return assistants.where((a) => a.type == 'built_in').toList();
  }

  // 获取自定义助手
  List<AssistantModel> getCustomAssistants() {
    final assistants = getAllAssistants();
    return assistants.where((a) => a.type == 'custom').toList();
  }

  // 初始化内置助手
  Future<void> initializeBuiltInAssistants() async {
    final box = HiveBoxes.getAssistantsBox();
    final builtInIds = ['default', 'quick', 'translate'];
    
    for (final id in builtInIds) {
      if (!box.containsKey(id)) {
        final assistant = _createBuiltInAssistant(id);
        await box.put(assistant.id, assistant);
      }
    }
  }

  AssistantModel _createBuiltInAssistant(String id) {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    switch (id) {
      case 'default':
        return AssistantModel(
          id: 'default',
          name: 'Cherry',
          prompt: '你是Cherry，一个友好、智能的AI助手。我致力于为用户提供有帮助、准确且安全的回答。',
          type: 'built_in',
          emoji: '🍒',
          description: '默认AI助手，适合日常对话和问题解答',
          createdAt: now,
          updatedAt: now,
        );
      case 'quick':
        return AssistantModel(
          id: 'quick',
          name: '快速助手',
          prompt: '请提供简洁、直接的回答。重点突出关键信息，避免冗长的解释。',
          type: 'built_in',
          emoji: '⚡',
          description: '快速回答，适合需要简洁回复的场景',
          createdAt: now,
          updatedAt: now,
        );
      case 'translate':
        return AssistantModel(
          id: 'translate',
          name: '翻译助手',
          prompt: '你是一个专业的翻译助手。请准确、自然地在不同语言之间进行翻译，保持原文的语义和语调。',
          type: 'built_in',
          emoji: '🌐',
          description: '专业翻译，支持多语言互译',
          createdAt: now,
          updatedAt: now,
        );
      default:
        throw ArgumentError('Unknown built-in assistant id: $id');
    }
  }

  // 从JSON导入助手
  Future<AssistantModel> importAssistantFromJson(Map<String, dynamic> json) async {
    try {
      final assistant = AssistantModel.fromJson(json);
      final box = HiveBoxes.getAssistantsBox();
      await box.put(assistant.id, assistant);
      return assistant;
    } catch (e) {
      throw Exception('Failed to import assistant: $e');
    }
  }

  // 导出助手为JSON
  Map<String, dynamic> exportAssistantToJson(String id) {
    final assistant = getAssistantById(id);
    if (assistant == null) {
      throw Exception('Assistant not found: $id');
    }
    return assistant.toJson();
  }

  // 搜索助手
  List<AssistantModel> searchAssistants(String query) {
    final assistants = getAllAssistants();
    final lowerQuery = query.toLowerCase();
    
    return assistants.where((assistant) {
      return assistant.name.toLowerCase().contains(lowerQuery) ||
             (assistant.description?.toLowerCase().contains(lowerQuery) ?? false) ||
             (assistant.group?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}