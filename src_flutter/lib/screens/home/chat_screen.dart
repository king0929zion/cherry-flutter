import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_state.dart';
import '../../providers/provider_settings.dart';
import '../../services/message_service.dart';
import '../../services/topic_service.dart';
import '../../widgets/message_input.dart';
import '../../services/block_service.dart';

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
                      child: GestureDetector(
                        onLongPress: () async {
                          final action = await showModalBottomSheet<String>(
                            context: context,
                            builder: (_) => SafeArea(
                              child: Wrap(children: [
                                ListTile(
                                  leading: const Icon(Icons.translate),
                                  title: const Text('翻译为中文'),
                                  onTap: () => Navigator.pop(context, 'zh'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.translate),
                                  title: const Text('Translate to English'),
                                  onTap: () => Navigator.pop(context, 'en'),
                                ),
                              ]),
                            ),
                          );
                          if (action != null) {
                            await ref.read(messageServiceProvider).translateMessage(
                                  messageId: m.id,
                                  lang: action == 'zh' ? '中文' : 'English',
                                  ref: ref,
                                );
                            ref.invalidate(translationBlockProvider(m.id));
                          }
                        },
                        child: Column(
                          crossAxisAlignment:
                              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.blue.shade600
                                    : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                m.content,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            Consumer(builder: (context, ref, _) {
                              final trans = ref.watch(translationBlockProvider(m.id));
                              return trans.when(
                                data: (b) => b == null
                                    ? const SizedBox.shrink()
                                    : Container(
                                        margin: const EdgeInsets.only(bottom: 6),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade800,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(b.content,
                                            style: const TextStyle(color: Colors.white70)),
                                      ),
                                loading: () => const SizedBox.shrink(),
                                error: (e, _) => const SizedBox.shrink(),
                              );
                            }),
                          ],
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
