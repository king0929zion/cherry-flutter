import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../data/boxes.dart';
import '../models/message.dart';
import '../models/message_block.dart';

class MessageService {
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal();

  final _uuid = const Uuid();

  // 获取话题的所有消息
  List<MessageModel> getMessagesByTopic(String topicId) {
    final box = HiveBoxes.getMessagesBox();
    return box.values
        .where((m) => m.topicId == topicId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // 根据ID获取消息
  MessageModel? getMessageById(String id) {
    final box = HiveBoxes.getMessagesBox();
    return box.get(id);
  }

  // 创建新消息
  Future<MessageModel> createMessage({
    required String role,
    required String assistantId,
    required String topicId,
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
    final now = DateTime.now().millisecondsSinceEpoch;
    final message = MessageModel(
      id: _uuid.v4(),
      role: role,
      assistantId: assistantId,
      topicId: topicId,
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
      createdAt: now,
      updatedAt: now,
    );

    final box = HiveBoxes.getMessagesBox();
    await box.put(message.id, message);
    return message;
  }

  // 更新消息
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
    final box = HiveBoxes.getMessagesBox();
    final message = box.get(id);
    if (message != null) {
      final updatedMessage = message.copyWith(
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
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await box.put(id, updatedMessage);
    }
  }

  // 删除消息
  Future<void> deleteMessage(String id) async {
    final box = HiveBoxes.getMessagesBox();
    await box.delete(id);
    
    // 同时删除相关的消息块
    final blockBox = HiveBoxes.getMessageBlocksBox();
    final blocks = blockBox.values.where((b) => b.messageId == id).toList();
    for (final block in blocks) {
      await blockBox.delete(block.id);
    }
  }

  // 获取消息的所有块
  List<MessageBlockModel> getMessageBlocks(String messageId) {
    final box = HiveBoxes.getMessageBlocksBox();
    return box.values
        .where((b) => b.messageId == messageId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // 创建消息块
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
    final now = DateTime.now().millisecondsSinceEpoch;
    final block = MessageBlockModel(
      id: _uuid.v4(),
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
      createdAt: now,
      updatedAt: now,
    );

    final box = HiveBoxes.getMessageBlocksBox();
    await box.put(block.id, block);
    return block;
  }

  // 更新消息块
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
    final box = HiveBoxes.getMessageBlocksBox();
    final block = box.get(id);
    if (block != null) {
      final updatedBlock = block.copyWith(
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
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await box.put(id, updatedBlock);
    }
  }

  // 删除消息块
  Future<void> deleteMessageBlock(String id) async {
    final box = HiveBoxes.getMessageBlocksBox();
    await box.delete(id);
  }

  // 批量删除话题的所有消息
  Future<void> deleteMessagesByTopic(String topicId) async {
    final box = HiveBoxes.getMessagesBox();
    final messages = box.values.where((m) => m.topicId == topicId).toList();
    
    for (final message in messages) {
      await deleteMessage(message.id);
    }
  }

  // 获取最后一条消息
  MessageModel? getLastMessage(String topicId) {
    final messages = getMessagesByTopic(topicId);
    if (messages.isEmpty) return null;
    return messages.last;
  }

  // 获取消息数量
  int getMessageCount(String topicId) {
    final box = HiveBoxes.getMessagesBox();
    return box.values.where((m) => m.topicId == topicId).length;
  }

  // 清空所有消息
  Future<void> clearAllMessages() async {
    final box = HiveBoxes.getMessagesBox();
    await box.clear();
    
    final blockBox = HiveBoxes.getMessageBlocksBox();
    await blockBox.clear();
  }

  // 翻译消息
  Future<void> translateMessage({
    required String messageId,
    required String lang,
    required dynamic ref,
  }) async {
    // TODO: 实现翻译逻辑
    // 这是一个占位实现，实际应该调用翻译API
  }

  // 重新生成助手消息
  Future<void> regenerateAssistant({
    required String assistantMessageId,
    required String topicId,
    required dynamic ref,
  }) async {
    // TODO: 实现重新生成逻辑
    // 这是一个占位实现，实际应该调用LLM API重新生成
  }

  // 使用LLM发送消息
  Future<void> sendWithLlm({
    required String topicId,
    required String text,
    required dynamic ref,
    List<dynamic>? attachments,
    List<dynamic>? mentions,
  }) async {
    // TODO: 实现发送消息逻辑
    // 这是一个占位实现，实际应该调用LLM API发送消息
  }
}