import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/boxes.dart';
import '../models/message.dart';
import '../utils/ids.dart';
import 'llm_service.dart';
import '../providers/provider_settings.dart';
import 'block_service.dart';
import '../providers/streaming.dart';
import 'web_search_service.dart';

class MessageService {
  Future<List<ChatMessage>> getMessagesByTopic(String topicId) async {
    final list = <ChatMessage>[];
    for (final v in Boxes.messages.values) {
      final m = v as Map;
      if (m['topicId'] == topicId) list.add(ChatMessage.fromJson(Map<String, dynamic>.from(m['data'])));
    }
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  Future<ChatMessage> createUserMessage({required String topicId, required String content}) async {
    final msg = ChatMessage(
      id: newId(),
      role: 'user',
      content: content,
      createdAt: DateTime.now(),
    );
    await Boxes.messages.put(msg.id, {
      'topicId': topicId,
      'data': msg.toJson(),
    });
    return msg;
  }

  Future<ChatMessage> createAssistantMessage({required String topicId, required String content}) async {
    final msg = ChatMessage(
      id: newId(),
      role: 'assistant',
      content: content,
      createdAt: DateTime.now(),
    );
    await Boxes.messages.put(msg.id, {
      'topicId': topicId,
      'data': msg.toJson(),
    });
    return msg;
  }

  Future<void> deleteByTopic(String topicId) async {
    final ks = Boxes.messages.keys.where((k) {
      final m = Boxes.messages.get(k) as Map?;
      return m != null && m['topicId'] == topicId;
    }).toList();
    for (final k in ks) {
      await Boxes.messages.delete(k);
    }
  }

  // Stub: simulate LLM; replace with real provider later
  Future<ChatMessage> simulateAssistantReply({required String topicId, required String prompt}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return createAssistantMessage(topicId: topicId, content: '回声：$prompt');
  }

  Future<void> sendWithLlm({
    required String topicId,
    required String text,
    required WidgetRef ref,
    List<PickedAttachment> attachments = const [],
  }) async {
    final trimmed = text.trim();
    if (trimmed.startsWith('/search ')) {
      final q = trimmed.substring(8).trim();
      final user = await createUserMessage(topicId: topicId, content: text);
      final summary = await ref.read(webSearchServiceProvider).searchSummary(q);
      await createAssistantMessage(topicId: topicId, content: '搜索结果：\n$summary');
      return;
    }

    final user = await createUserMessage(topicId: topicId, content: text);
    // persist attachments as blocks
    for (final a in attachments) {
      await ref.read(blockServiceProvider).addAttachmentBlock(
            messageId: user.id,
            name: a.name,
            mime: a.mime,
            bytes: a.bytes,
          );
    }
    final history = await getMessagesByTopic(topicId);
    final assistant = await createAssistantMessage(topicId: topicId, content: '');
    String buffer = '';
    final cfg = ref.read(providerSettingsProvider);
    final token = ref.read(streamingProvider.notifier).start(topicId);
    await ref.read(llmServiceProvider).streamComplete(
      context: history,
      cfg: cfg,
      cancelToken: token,
      onDelta: (d) async {
        buffer += d;
        final updated = ChatMessage(
          id: assistant.id,
          role: assistant.role,
          content: buffer,
          createdAt: assistant.createdAt,
        );
        await Boxes.messages.put(assistant.id, {
          'topicId': topicId,
          'data': updated.toJson(),
        });
      },
    );
    ref.read(streamingProvider.notifier).stop(topicId);
  }

  Future<void> translateMessage({required String messageId, required String lang, required WidgetRef ref}) async {
    // find message
    Map? raw;
    for (final key in Boxes.messages.keys) {
      final m = Boxes.messages.get(key) as Map?;
      if (m != null) {
        final data = Map<String, dynamic>.from(m['data'] as Map);
        if (data['id'] == messageId) {
          raw = m;
          break;
        }
      }
    }
    if (raw == null) return;
    final msg = ChatMessage.fromJson(Map<String, dynamic>.from(raw['data'] as Map));
    final cfg = ref.read(providerSettingsProvider);
    final prompt = '请将以下内容翻译为$lang：\n\n${msg.content}';
    final reply = await ref.read(llmServiceProvider).complete(context: [
      ChatMessage(id: newId(), role: 'system', content: '你是一个专业的翻译助手。', createdAt: DateTime.now()),
      ChatMessage(id: newId(), role: 'user', content: prompt, createdAt: DateTime.now()),
    ], cfg: cfg);
    await ref.read(blockServiceProvider).upsertTranslation(messageId: messageId, text: reply);
  }
}

final messageServiceProvider = Provider<MessageService>((ref) => MessageService());

final messagesProvider = FutureProvider.family<List<ChatMessage>, String>((ref, topicId) async {
  final svc = ref.read(messageServiceProvider);
  return svc.getMessagesByTopic(topicId);
});
