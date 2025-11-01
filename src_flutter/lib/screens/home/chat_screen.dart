import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_state.dart';
import '../../providers/provider_settings.dart';
import '../../services/message_service.dart';
import '../../services/topic_service.dart';
import '../../widgets/message_input.dart';

class ChatScreen extends ConsumerWidget {
  final String topicId;
  const ChatScreen({super.key, required this.topicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveTopic = topicId == 'default'
        ? ref.watch(currentTopicProvider).maybeWhen(data: (t) => t.id, orElse: () => null)
        : topicId;

    if (effectiveTopic == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final messages = ref.watch(messagesProvider(effectiveTopic));
    final cfg = ref.watch(providerSettingsProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (cfg.apiKey.isEmpty)
              Material(
                color: Colors.amber.shade100,
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('请先在 设置 -> 供应商 设置 OpenAI API Key 才能调用模型'),
                ),
              ),
            Expanded(
              child: messages.when(
                data: (list) => ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final m = list[i];
                    final isUser = m.role == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue.shade600 : Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          m.content,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('加载失败: $e')),
              ),
            ),
            MessageInput(onSubmit: (text) async {
              final msgSvc = ref.read(messageServiceProvider);
              final topicSvc = ref.read(topicServiceProvider);
              // Ensure topic exists and set current if default route
              String tid = effectiveTopic;
              await msgSvc.sendWithLlm(topicId: tid, text: text, ref: ref);
              // refresh
              ref.invalidate(messagesProvider(tid));
            }),
          ],
        ),
      ),
    );
  }
}
