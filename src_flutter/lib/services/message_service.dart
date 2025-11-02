import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/boxes.dart';
import '../models/attachment.dart';
import '../models/message.dart';
import '../providers/provider_settings.dart';
import '../providers/streaming.dart';
import '../services/block_service.dart';
import '../services/llm_service.dart';
import '../services/topic_service.dart';
import '../services/web_search_service.dart';
import '../utils/ids.dart';

class MessageService {
  Future<List<ChatMessage>> getMessagesByTopic(String topicId) async {
    final list = <ChatMessage>[];
    for (final v in Boxes.messages.values) {
      final m = v as Map;
      if (m['topicId'] == topicId) {
        list.add(ChatMessage.fromJson(Map<String, dynamic>.from(m['data'] as Map)));
      }
    }
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  Future<ChatMessage> createUserMessage({
    required String topicId,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    final msg = ChatMessage(
      id: newId(),
      role: 'user',
      content: content,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
    await Boxes.messages.put(msg.id, {
      'topicId': topicId,
      'data': msg.toJson(),
    });
    return msg;
  }

  Future<ChatMessage> createAssistantMessage({
    required String topicId,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    final msg = ChatMessage(
      id: newId(),
      role: 'assistant',
      content: content,
      createdAt: DateTime.now(),
      metadata: metadata,
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

  Future<ChatMessage> simulateAssistantReply({
    required String topicId,
    required String prompt,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return createAssistantMessage(topicId: topicId, content: '（模拟回复）$prompt');
  }

  Future<void> sendWithLlm({
    required String topicId,
    required String text,
    required WidgetRef ref,
    List<PickedAttachment> attachments = const [],
    List<String> mentions = const [],
  }) async {
    final trimmed = text.trim();
    if (trimmed.startsWith('/search ')) {
      final q = trimmed.substring(8).trim();
      await createUserMessage(
        topicId: topicId,
        content: text,
        metadata: {
          if (mentions.isNotEmpty) 'mentions': mentions,
        },
      );
      final summary = await ref.read(webSearchServiceProvider).searchSummary(q);
      await createAssistantMessage(
        topicId: topicId,
        content: '搜索结果：
$summary',
        metadata: {
          if (mentions.isNotEmpty) 'mentions': mentions,
        },
      );
      return;
    }

    final user = await createUserMessage(
      topicId: topicId,
      content: text,
      metadata: {
        if (mentions.isNotEmpty) 'mentions': mentions,
      },
    );
    for (final a in attachments) {
      await ref.read(blockServiceProvider).addAttachmentBlock(
            messageId: user.id,
            name: a.name,
            mime: a.mime,
            bytes: a.bytes,
          );
    }

    final history = await getMessagesByTopic(topicId);
    final assistant = await createAssistantMessage(
      topicId: topicId,
      content: '',
      metadata: {
        if (mentions.isNotEmpty) 'mentions': mentions,
      },
    );

    String buffer = '';
    final cfg = ref.read(providerSettingsProvider);
    final token = ref.read(streamingProvider.notifier).start(topicId);
    await ref.read(llmServiceProvider).streamComplete(
      context: history,
      cfg: cfg,
      cancelToken: token,
      onDelta: (chunk) async {
        buffer += chunk;
        final updated = ChatMessage(
          id: assistant.id,
          role: assistant.role,
          content: buffer,
          createdAt: assistant.createdAt,
          metadata: assistant.metadata,
        );
        await Boxes.messages.put(assistant.id, {
          'topicId': topicId,
          'data': updated.toJson(),
        });
      },
    );
    ref.read(streamingProvider.notifier).stop(topicId);

    try {
      final topics = await ref.read(topicServiceProvider).getTopics();
      final target = topics.firstWhere((e) => e.id == topicId);
      if (target.name == '新主题' || target.name.trim().length < 3) {
        final hist = await getMessagesByTopic(topicId);
        final sample = hist.reversed.take(6).toList().reversed.toList();
        final prompt = '基于以下对话生成一个不超过10个字的标题（不含标点）：
' +
            sample.map((m) => '${m.role}: ${m.content}').join('
');
        final title = await ref.read(llmServiceProvider).complete(
              context: [
                ChatMessage(
                  id: newId(),
                  role: 'system',
                  content: '你是标题生成器，只输出标题本身',
                  createdAt: DateTime.now(),
                ),
                ChatMessage(
                  id: newId(),
                  role: 'user',
                  content: prompt,
                  createdAt: DateTime.now(),
                ),
              ],
              cfg: cfg,
            );
        final finalTitle = title.trim().replaceAll(RegExp(r'[
]'), '').replaceAll('"', '');
        if (finalTitle.isNotEmpty) {
          await ref.read(topicServiceProvider).renameTopic(topicId, finalTitle);
        }
      }
    } catch (_) {}
  }

  Future<void> deleteMessage(String messageId) async {
    await Boxes.messages.delete(messageId);
    final toDelete = <dynamic>[];
    for (final key in Boxes.blocks.keys) {
      final m = Boxes.blocks.get(key) as Map?;
      if (m != null && m['messageId'] == messageId) {
        toDelete.add(key);
      }
    }
    for (final k in toDelete) {
      await Boxes.blocks.delete(k);
    }
  }

  Future<void> regenerateAssistant({
    required String assistantMessageId,
    required String topicId,
    required WidgetRef ref,
  }) async {
    final msgs = await getMessagesByTopic(topicId);
    final idx = msgs.indexWhere((m) => m.id == assistantMessageId);
    if (idx <= 0) return;
    String text = '';
    for (int i = idx - 1; i >= 0; i--) {
      if (msgs[i].role == 'user') {
        text = msgs[i].content;
        break;
      }
    }
    if (text.isEmpty) {
      text = '请基于上述对话重新回答上一条提问。';
    }
    await sendWithLlm(topicId: topicId, text: text, ref: ref);
  }

  Future<void> translateMessage({
    required String messageId,
    required String lang,
    required WidgetRef ref,
  }) async {
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
    final prompt = '请将以下内容翻译为$lang：

${msg.content}';
    final reply = await ref.read(llmServiceProvider).complete(
          context: [
            ChatMessage(
              id: newId(),
              role: 'system',
              content: '你是一位专业的翻译助手',
              createdAt: DateTime.now(),
            ),
            ChatMessage(
              id: newId(),
              role: 'user',
              content: prompt,
              createdAt: DateTime.now(),
            ),
          ],
          cfg: cfg,
        );
    await ref.read(blockServiceProvider).upsertTranslation(
          messageId: messageId,
          text: reply,
        );
  }
}

final messageServiceProvider = Provider<MessageService>((ref) => MessageService());

final messagesProvider = FutureProvider.family<List<ChatMessage>, String>((ref, topicId) async {
  final svc = ref.read(messageServiceProvider);
  return svc.getMessagesByTopic(topicId);
});
