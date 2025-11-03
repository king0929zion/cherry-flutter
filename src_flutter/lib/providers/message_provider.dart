import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message.dart';
import '../models/message_block.dart';
import '../services/message_service.dart';

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

// 消息状态通知者（使用 FutureProvider.family 简化实现）
final messageNotifierProvider = FutureProvider.family<List<MessageModel>, String>((ref, topicId) async {
  final service = ref.read(messageServiceProvider);
  return service.getMessagesByTopic(topicId);
});

// 消息操作提供者
final messageActionsProvider = Provider.family<MessageActions, String>((ref, topicId) {
  return MessageActions(ref, topicId);
});

class MessageActions {
  final Ref _ref;
  final String _topicId;
  
  MessageActions(this._ref, this._topicId);
  
  MessageService get _service => _ref.read(messageServiceProvider);
  
  Future<void> refresh() async {
    _ref.invalidate(messageNotifierProvider(_topicId));
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
      // Error handling
    }
  }

  Future<void> deleteMessage(String id) async {
    try {
      await _service.deleteMessage(id);
      await refresh();
    } catch (error, stackTrace) {
      // Error handling
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
      // Error handling
    }
  }

  Future<void> deleteMessageBlock(String id) async {
    try {
      await _service.deleteMessageBlock(id);
    } catch (error, stackTrace) {
      // Error handling
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
      // Error handling
    }
  }
}