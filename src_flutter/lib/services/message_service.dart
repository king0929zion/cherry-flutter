import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/boxes.dart';
import '../models/message.dart';
import '../utils/ids.dart';
import 'llm_service.dart';
import '../providers/provider_settings.dart';

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

  Future<void> sendWithLlm({required String topicId, required String text, required WidgetRef ref}) async {
    await createUserMessage(topicId: topicId, content: text);
    final history = await getMessagesByTopic(topicId);
    final assistant = await createAssistantMessage(topicId: topicId, content: '');
    String buffer = '';
    final cfg = ref.read(providerSettingsProvider);
    await ref.read(llmServiceProvider).streamComplete(
      context: history,
      cfg: cfg,
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
  }
}

final messageServiceProvider = Provider<MessageService>((ref) => MessageService());

final messagesProvider = FutureProvider.family<List<ChatMessage>, String>((ref, topicId) async {
  final svc = ref.read(messageServiceProvider);
  return svc.getMessagesByTopic(topicId);
});
