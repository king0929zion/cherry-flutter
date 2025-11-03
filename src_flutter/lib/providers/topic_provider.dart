import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/topic_service.dart';
import '../models/topic.dart';

// 话题服务提供者
final topicServiceProvider = Provider<TopicService>((ref) {
  return TopicService();
});

// 所有话题提供者
final topicsProvider = Provider<List<TopicModel>>((ref) {
  final service = ref.watch(topicServiceProvider);
  return service.getAllTopics();
});

// 当前话题提供者
final currentTopicProvider = StateProvider<TopicModel?>((ref) {
  return null;
});

// 根据ID获取话题提供者
final topicProvider = Provider.family<TopicModel?, String>((ref, id) {
  final service = ref.watch(topicServiceProvider);
  return service.getTopicById(id);
});

// 话题状态通知者
class TopicNotifier extends Notifier<AsyncValue<List<TopicModel>>> {
  TopicService get _service => ref.read(topicServiceProvider);

  @override
  AsyncValue<List<TopicModel>> build() {
    _loadTopics();
    return const AsyncValue.loading();
  }

  Future<void> _loadTopics() async {
    state = const AsyncValue.loading();
    try {
      final topics = _service.getAllTopics();
      state = AsyncValue.data(topics);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadTopics();
  }

  Future<TopicModel> createTopic({
    required String assistantId,
    required String name,
  }) async {
    try {
      final topic = await _service.createTopic(
        assistantId: assistantId,
        name: name,
      );
      await refresh();
      return topic;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateTopic(String id, {
    String? name,
    String? assistantId,
    bool? isLoading,
  }) async {
    try {
      await _service.updateTopic(
        id,
        name: name,
        assistantId: assistantId,
        isLoading: isLoading,
      );
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTopic(String id) async {
    try {
      await _service.deleteTopic(id);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTopics(List<String> ids) async {
    try {
      await _service.deleteTopics(ids);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<TopicModel> ensureDefaultTopic() async {
    try {
      final topic = await _service.ensureDefaultTopic();
      await refresh();
      return topic;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  List<TopicModel> searchTopics(String query) {
    return _service.searchTopics(query);
  }

  List<TopicModel> getRecentTopics({int limit = 10}) {
    return _service.getRecentTopics(limit: limit);
  }

  Future<void> updateTopicTimestamp(String id) async {
    try {
      await _service.updateTopicTimestamp(id);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  int getMessageCount(String topicId) {
    return _service.getMessageCount(topicId);
  }

  Future<void> clearAllTopics() async {
    try {
      await _service.clearAllTopics();
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// 话题通知者提供者
final topicNotifierProvider = NotifierProvider<TopicNotifier, AsyncValue<List<TopicModel>>>(() {
  return TopicNotifier();
});