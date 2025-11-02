import 'package:uuid/uuid.dart';
import '../data/boxes.dart';
import '../models/topic.dart';

class TopicService {
  static final TopicService _instance = TopicService._internal();
  factory TopicService() => _instance;
  TopicService._internal();

  final _uuid = const Uuid();

  // 获取所有话题
  List<TopicModel> getAllTopics() {
    final box = HiveBoxes.getTopicsBox();
    return box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // 根据ID获取话题
  TopicModel? getTopicById(String id) {
    final box = HiveBoxes.getTopicsBox();
    return box.get(id);
  }

  // 创建新话题
  Future<TopicModel> createTopic({
    required String assistantId,
    required String name,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final topic = TopicModel(
      id: _uuid.v4(),
      assistantId: assistantId,
      name: name,
      createdAt: now,
      updatedAt: now,
    );

    final box = HiveBoxes.getTopicsBox();
    await box.put(topic.id, topic);
    return topic;
  }

  // 更新话题
  Future<void> updateTopic(String id, {
    String? name,
    String? assistantId,
    bool? isLoading,
  }) async {
    final box = HiveBoxes.getTopicsBox();
    final topic = box.get(id);
    if (topic != null) {
      final updatedTopic = topic.copyWith(
        name: name,
        assistantId: assistantId,
        isLoading: isLoading,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await box.put(id, updatedTopic);
    }
  }

  // 删除话题
  Future<void> deleteTopic(String id) async {
    final box = HiveBoxes.getTopicsBox();
    await box.delete(id);
    
    // 同时删除相关的消息
    final messageBox = HiveBoxes.getMessagesBox();
    final messages = messageBox.values.where((m) => m.topicId == id).toList();
    for (final message in messages) {
      await messageBox.delete(message.id);
    }
    
    // 删除相关的消息块
    final blockBox = HiveBoxes.getMessageBlocksBox();
    for (final message in messages) {
      final blocks = blockBox.values.where((b) => b.messageId == message.id).toList();
      for (final block in blocks) {
        await blockBox.delete(block.id);
      }
    }
  }

  // 获取或创建默认话题
  Future<TopicModel> ensureDefaultTopic() async {
    const defaultId = 'default';
    final box = HiveBoxes.getTopicsBox();
    
    TopicModel? defaultTopic = box.get(defaultId);
    if (defaultTopic == null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      defaultTopic = TopicModel(
        id: defaultId,
        assistantId: 'default',
        name: '默认对话',
        createdAt: now,
        updatedAt: now,
      );
      await box.put(defaultTopic.id, defaultTopic);
    }
    
    return defaultTopic;
  }

  // 搜索话题
  List<TopicModel> searchTopics(String query) {
    final topics = getAllTopics();
    final lowerQuery = query.toLowerCase();
    
    return topics.where((topic) {
      return topic.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // 获取最近的话题
  List<TopicModel> getRecentTopics({int limit = 10}) {
    final topics = getAllTopics();
    return topics.take(limit).toList();
  }

  // 更新话题的最后更新时间
  Future<void> updateTopicTimestamp(String id) async {
    final box = HiveBoxes.getTopicsBox();
    final topic = box.get(id);
    if (topic != null) {
      final updatedTopic = topic.copyWith(
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await box.put(id, updatedTopic);
    }
  }

  // 获取话题的消息数量
  int getMessageCount(String topicId) {
    final messageBox = HiveBoxes.getMessagesBox();
    return messageBox.values.where((m) => m.topicId == topicId).length;
  }

  // 批量删除话题
  Future<void> deleteTopics(List<String> ids) async {
    for (final id in ids) {
      await deleteTopic(id);
    }
  }

  // 清空所有话题
  Future<void> clearAllTopics() async {
    final topics = getAllTopics();
    final topicIds = topics.map((t) => t.id).toList();
    await deleteTopics(topicIds);
  }
}