import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/assistant_service.dart';
import '../models/assistant.dart';

// 助手服务提供者
final assistantServiceProvider = Provider<AssistantService>((ref) {
  return AssistantService();
});

// 所有助手提供者（异步，保证内置助手初始化）
final assistantsProvider = FutureProvider<List<AssistantModel>>((ref) async {
  final service = ref.watch(assistantServiceProvider);
  await service.initializeBuiltInAssistants();
  return service.getAllAssistants();
});

// 内置助手提供者（保留，返回同步列表）
final builtInAssistantsProvider = Provider<List<AssistantModel>>((ref) {
  final service = ref.watch(assistantServiceProvider);
  return service.getBuiltInAssistants();
});

// 自定义助手提供者
final customAssistantsProvider = Provider<List<AssistantModel>>((ref) {
  final service = ref.watch(assistantServiceProvider);
  return service.getCustomAssistants();
});

// 根据ID获取助手提供者
final assistantProvider = Provider.family<AssistantModel?, String>((ref, id) {
  final service = ref.watch(assistantServiceProvider);
  return service.getAssistantById(id);
});

// 助手状态通知者
class AssistantNotifier extends StateNotifier<AsyncValue<List<AssistantModel>>> {
  final AssistantService _service;

  AssistantNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadAssistants();
  }

  Future<void> _loadAssistants() async {
    state = const AsyncValue.loading();
    try {
      await _service.initializeBuiltInAssistants();
      final assistants = _service.getAllAssistants();
      state = AsyncValue.data(assistants);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadAssistants();
  }

  Future<void> createAssistant({
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
    List<String>? tags,
    List<String>? group,
    String? websearchProviderId,
  }) async {
    try {
      await _service.createAssistant(
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
      );
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

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
    List<String>? tags,
    List<String>? group,
    String? websearchProviderId,
  }) async {
    try {
      await _service.updateAssistant(
        id,
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
      );
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteAssistant(String id) async {
    try {
      await _service.deleteAssistant(id);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> importAssistant(Map<String, dynamic> json) async {
    try {
      await _service.importAssistantFromJson(json);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  List<AssistantModel> searchAssistants(String query) {
    return _service.searchAssistants(query);
  }
}

// 助手通知者提供者
final assistantNotifierProvider = StateNotifierProvider<AssistantNotifier, AsyncValue<List<AssistantModel>>>((ref) {
  final service = ref.watch(assistantServiceProvider);
  return AssistantNotifier(service);
});