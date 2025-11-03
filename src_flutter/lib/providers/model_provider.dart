import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/model.dart';
import '../services/model_service.dart';
import '../providers/provider_settings.dart';

// 导出modelServiceProvider供其他文件使用
export '../services/model_service.dart' show modelServiceProvider;

final modelsProvider = FutureProvider<List<AIModel>>((ref) async {
  final settings = ref.watch(providerSettingsProvider);
  final service = ref.read(modelServiceProvider);
  return service.getAvailableModels(settings);
});

final customModelsProvider = FutureProvider<List<AIModel>>((ref) async {
  final service = ref.read(modelServiceProvider);
  return service.getCustomModels();
});

class ModelNotifier extends Notifier<AIModel?> {
  @override
  AIModel? build() {
    return null;
  }

  void selectModel(AIModel model) {
    state = model;
  }

  void clearModel() {
    state = null;
  }
}

final selectedModelProvider = NotifierProvider<ModelNotifier, AIModel?>(ModelNotifier.new);

class ModelSearchNotifier extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void updateSearch(String query) {
    state = query;
  }
}

final modelSearchProvider = NotifierProvider<ModelSearchNotifier, String>(ModelSearchNotifier.new);

final filteredModelsProvider = Provider<List<AIModel>>((ref) {
  final searchQuery = ref.watch(modelSearchProvider);
  final modelsAsync = ref.watch(modelsProvider);
  
  return modelsAsync.when(
    data: (models) {
      if (searchQuery.isEmpty) return models;
      
      final query = searchQuery.toLowerCase();
      return models.where((model) {
        return model.name.toLowerCase().contains(query) ||
               model.providerName.toLowerCase().contains(query) ||
               model.description.toLowerCase().contains(query);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});