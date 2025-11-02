import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/message_service.dart';
import '../models/message.dart';
import '../models/message_block.dart';

// 消息服务提供者
final messageServiceProvider = Provider<MessageService>((ref) {
  return MessageService();
});

// 话题消息提供者
final messagesProvider = Provider.family<List<MessageModel>, String>((ref, topicId) {
  final service = ref.watch(messageServiceProvider);
  return service.getMessagesByTopic(topicId);
});

// 消息块提供者
final messageBlocksProvider = Provider.family<List<MessageBlockModel>, String>((ref, messageId) {
  final service = ref.watch(messageServiceProvider);
  return service.getMessageBlocks(messageId);
});

// 根据ID获取消息提供者
final messageProvider = Provider.family<MessageModel?, String>((ref, id) {
  final service = ref.watch(messageServiceProvider);
  return service.getMessageById(id);
});

// 消息状态通知者
class MessageNotifier extends StateNotifier<AsyncValue<List<MessageModel>>> {
  final MessageService _service;
  final String _topicId;

  MessageNotifier(this._service, this._topicId) : super(const AsyncValue.loading()) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    state = const AsyncValue.loading();
    try {
      final messages = _service.getMessagesByTopic(_topicId);
      state = AsyncValue.data(messages);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadMessages();
  }

  Future<MessageModel> createMessage({
    required String role,
    required String assistantId,
    String status = 'pending',
    String? modelId,
    String? model,
    String? type,
    bool useful = true,
    String? askId,
    String? mentions,
    String? usage,
    String? metrics,
    String? multiModelMessageStyle,
    bool foldSelected = false,
  }) async {
    try {
      final message = await _service.createMessage(
        role: role,
        assistantId: assistantId,
        topicId: _topicId,
        status: status,
        modelId: modelId,
        model: model,
        type: type,
        useful: useful,
        askId: askId,
        mentions: mentions,
        usage: usage,
        metrics: metrics,
        multiModelMessageStyle: multiModelMessageStyle,
        foldSelected: foldSelected,
      );
      await refresh();
      return message;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateMessage(String id, {
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
  }) async {
    try {
      await _service.updateMessage(
        id,
        status: status,
        modelId: modelId,
        model: model,
        type: type,
        useful: useful,
        askId: askId,
        mentions: mentions,
        usage: usage,
        metrics: metrics,
        multiModelMessageStyle: multiModelMessageStyle,
        foldSelected: foldSelected,
      );
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteMessage(String id) async {
    try {
      await _service.deleteMessage(id);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<MessageBlockModel> createMessageBlock({
    required String messageId,
    required MessageBlockType type,
    required MessageBlockStatus status,
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
  }) async {
    try {
      final block = await _service.createMessageBlock(
        messageId: messageId,
        type: type,
        status: status,
        model: model,
        metadata: metadata,
        error: error,
        content: content,
        language: language,
        url: url,
        file: file,
        toolId: toolId,
        toolName: toolName,
        arguments: arguments,
        sourceBlockId: sourceBlockId,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        response: response,
        knowledge: knowledge,
        thinkingMillsec: thinkingMillsec,
        knowledgeBaseIds: knowledgeBaseIds,
        citationReferences: citationReferences,
      );
      return block;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateMessageBlock(String id, {
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
  }) async {
    try {
      await _service.updateMessageBlock(
        id,
        status: status,
        model: model,
        metadata: metadata,
        error: error,
        content: content,
        language: language,
        url: url,
        file: file,
        toolId: toolId,
        toolName: toolName,
        arguments: arguments,
        sourceBlockId: sourceBlockId,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        response: response,
        knowledge: knowledge,
        thinkingMillsec: thinkingMillsec,
        knowledgeBaseIds: knowledgeBaseIds,
        citationReferences: citationReferences,
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteMessageBlock(String id) async {
    try {
      await _service.deleteMessageBlock(id);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  MessageModel? getLastMessage() {
    return _service.getLastMessage(_topicId);
  }

  int getMessageCount() {
    return _service.getMessageCount(_topicId);
  }

  Future<void> clearAllMessages() async {
    try {
      await _service.clearAllMessages();
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// 消息通知者提供者
final messageNotifierProvider = StateNotifierProvider.family<MessageNotifier, AsyncValue<List<MessageModel>>, String>((ref, topicId) {
  final service = ref.watch(messageServiceProvider);
  return MessageNotifier(service, topicId);
});