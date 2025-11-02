import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/model.dart';
import '../providers/provider_settings.dart';
import 'prefs_service.dart';

class ModelService {
  static const String _kCustomModelsKey = 'custom_models';
  
  static final List<AIModel> _builtInModels = [
    // OpenAI Models
    AIModel(
      id: 'gpt-4o',
      name: 'gpt-4o',
      provider: 'openai',
      description: 'OpenAI 最新的多模态模型，功能强大且响应迅速',
      contextLength: 128000,
      maxTokens: 4096,
      inputPrice: 0.005,
      outputPrice: 0.015,
      capabilities: ['text', 'vision', 'function_calling'],
    ),
    AIModel(
      id: 'gpt-4o-mini',
      name: 'gpt-4o-mini',
      provider: 'openai',
      description: '轻量级 GPT-4o，成本更低，速度更快',
      contextLength: 128000,
      maxTokens: 16384,
      inputPrice: 0.00015,
      outputPrice: 0.0006,
      capabilities: ['text', 'vision', 'function_calling'],
    ),
    AIModel(
      id: 'gpt-4-turbo',
      name: 'gpt-4-turbo',
      provider: 'openai',
      description: '高性能 GPT-4 模型，适合复杂任务',
      contextLength: 128000,
      maxTokens: 4096,
      inputPrice: 0.01,
      outputPrice: 0.03,
      capabilities: ['text', 'vision', 'function_calling'],
    ),
    AIModel(
      id: 'gpt-3.5-turbo',
      name: 'gpt-3.5-turbo',
      provider: 'openai',
      description: '经济实用的通用模型',
      contextLength: 16385,
      maxTokens: 4096,
      inputPrice: 0.0005,
      outputPrice: 0.0015,
      capabilities: ['text', 'function_calling'],
    ),
    
    // Anthropic Models
    AIModel(
      id: 'claude-3-5-sonnet-20241022',
      name: 'claude-3-5-sonnet-20241022',
      provider: 'anthropic',
      description: 'Anthropic 最新的 Sonnet 模型，平衡性能与成本',
      contextLength: 200000,
      maxTokens: 8192,
      inputPrice: 0.003,
      outputPrice: 0.015,
      capabilities: ['text', 'vision', 'function_calling'],
    ),
    AIModel(
      id: 'claude-3-haiku-20240307',
      name: 'claude-3-haiku-20240307',
      provider: 'anthropic',
      description: '快速响应的 Haiku 模型',
      contextLength: 200000,
      maxTokens: 4096,
      inputPrice: 0.00025,
      outputPrice: 0.00125,
      capabilities: ['text', 'vision'],
    ),
    
    // Google Models
    AIModel(
      id: 'gemini-1.5-pro',
      name: 'gemini-1.5-pro',
      provider: 'google',
      description: 'Google 的先进多模态模型',
      contextLength: 2097152,
      maxTokens: 8192,
      inputPrice: 0.0035,
      outputPrice: 0.0105,
      capabilities: ['text', 'vision', 'function_calling'],
    ),
    AIModel(
      id: 'gemini-1.5-flash',
      name: 'gemini-1.5-flash',
      provider: 'google',
      description: 'Google 的快速响应模型',
      contextLength: 1048576,
      maxTokens: 8192,
      inputPrice: 0.00015,
      outputPrice: 0.0006,
      capabilities: ['text', 'vision', 'function_calling'],
    ),
  ];

  Future<List<AIModel>> getAvailableModels(ProviderSettings settings) async {
    final customModels = await getCustomModels();
    final providerModels = _builtInModels.where((m) => m.provider == settings.providerId);
    
    // 尝试从 API 获取最新模型列表
    try {
      final apiModels = await fetchModelsFromAPI(settings);
      return [...customModels, ...apiModels, ...providerModels];
    } catch (e) {
      return [...customModels, ...providerModels];
    }
  }

  Future<List<AIModel>> fetchModelsFromAPI(ProviderSettings settings) async {
    if (settings.apiKey.isEmpty || settings.baseUrl.isEmpty) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('${settings.baseUrl}/models'),
        headers: {
          'Authorization': 'Bearer ${settings.apiKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = <AIModel>[];
        
        if (data['data'] != null) {
          for (final model in data['data']) {
            models.add(AIModel(
              id: model['id'],
              name: model['id'],
              provider: settings.providerId,
              description: _getModelDescription(model['id']),
              contextLength: _estimateContextLength(model['id']),
              capabilities: _estimateCapabilities(model['id']),
            ));
          }
        }
        
        return models;
      }
    } catch (e) {
      // 静默处理错误，返回空列表
    }
    
    return [];
  }

  Future<List<AIModel>> getCustomModels() async {
    final data = prefsService.getString(_kCustomModelsKey);
    if (data == null) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => AIModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addCustomModel(AIModel model) async {
    final models = await getCustomModels();
    models.add(model);
    await _saveCustomModels(models);
  }

  Future<void> removeCustomModel(String modelId) async {
    final models = await getCustomModels();
    models.removeWhere((m) => m.id == modelId);
    await _saveCustomModels(models);
  }

  Future<void> updateCustomModel(AIModel model) async {
    final models = await getCustomModels();
    final index = models.indexWhere((m) => m.id == model.id);
    if (index != -1) {
      models[index] = model;
      await _saveCustomModels(models);
    }
  }

  Future<void> _saveCustomModels(List<AIModel> models) async {
    final data = jsonEncode(models.map((m) => m.toJson()).toList());
    await prefsService.setString(_kCustomModelsKey, data);
  }

  String _getModelDescription(String modelId) {
    final id = modelId.toLowerCase();
    if (id.contains('gpt-4')) {
      if (id.contains('turbo')) return '高性能 GPT-4 模型';
      if (id.contains('mini')) return '轻量级 GPT-4 模型';
      return 'GPT-4 模型';
    }
    if (id.contains('gpt-3.5')) return 'GPT-3.5 模型';
    if (id.contains('claude')) {
      if (id.contains('sonnet')) return 'Claude Sonnet 模型';
      if (id.contains('haiku')) return 'Claude Haiku 模型';
      if (id.contains('opus')) return 'Claude Opus 模型';
      return 'Claude 模型';
    }
    if (id.contains('gemini')) {
      if (id.contains('pro')) return 'Gemini Pro 模型';
      if (id.contains('flash')) return 'Gemini Flash 模型';
      return 'Gemini 模型';
    }
    return 'AI 模型';
  }

  int _estimateContextLength(String modelId) {
    final id = modelId.toLowerCase();
    if (id.contains('gpt-4')) {
      if (id.contains('turbo') || id.contains('preview')) return 128000;
      return 8192;
    }
    if (id.contains('gpt-3.5')) return 16385;
    if (id.contains('claude')) {
      if (id.contains('3')) return 200000;
      return 100000;
    }
    if (id.contains('gemini')) {
      if (id.contains('1.5')) return 1048576;
      return 32768;
    }
    return 4096;
  }

  List<String> _estimateCapabilities(String modelId) {
    final id = modelId.toLowerCase();
    final capabilities = <String>['text'];
    
    if (id.contains('gpt-4') || id.contains('claude-3') || id.contains('gemini')) {
      capabilities.addAll(['vision', 'function_calling']);
    }
    if (id.contains('gpt-3.5') && id.contains('turbo')) {
      capabilities.add('function_calling');
    }
    
    return capabilities;
  }
}

final modelServiceProvider = Provider<ModelService>((ref) => ModelService());