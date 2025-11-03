import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../providers/app_state.dart';
import '../../providers/streaming.dart';
import '../../providers/assistant_provider.dart';
import '../../providers/message_provider.dart';
import '../../providers/topic_provider.dart';
import '../../services/block_service.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/message_input.dart';
import '../../models/block.dart';
import '../../models/assistant.dart';
import '../../models/topic.dart';
import 'widgets/attachment_tile.dart';
import 'widgets/chat_header.dart';

final topicDetailsProvider = FutureProvider.family<TopicModel, String>((ref, topicId) async {
  final svc = ref.read(topicServiceProvider);
  final topic = await svc.getTopicById(topicId);
  if (topic != null) return topic;
  return svc.ensureDefaultTopic();
});

class ChatScreen extends ConsumerWidget {
  final String topicId;
  const ChatScreen({super.key, required this.topicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveTopic = topicId; // 'default' will be ensured in provider
    final messagesAsync = ref.watch(messageNotifierProvider(effectiveTopic));
    final streamingMap = ref.watch(streamingProvider);
    final isStreaming = streamingMap.containsKey(effectiveTopic);
    final topicAsync = ref.watch(topicDetailsProvider(effectiveTopic));
    final assistantsAsync = ref.watch(assistantsProvider);

    return topicAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('加载话题信息失败: $error')),
      ),
      data: (topic) {
        final assistants = assistantsAsync.maybeWhen(
          data: (list) => list,
          orElse: () => const <AssistantModel>[],
        );
        AssistantModel currentAssistant;
        try {
          currentAssistant = assistants.firstWhere((a) => a.id == topic.assistantId);
        } catch (_) {
          currentAssistant = AssistantModel(
            id: 'default',
            name: '默认助手',
            prompt: '',
            type: 'built_in',
            emoji: '🤖',
            description: '默认助手',
            createdAt: DateTime.now().millisecondsSinceEpoch,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          );
        }

        final assistantList = assistants.isEmpty ? [currentAssistant] : assistants;

        return Scaffold(
          appBar: ChatHeader(topicId: effectiveTopic),
          body: Column(
            children: [
              if (isStreaming)
                Material(
                  color: Colors.blueGrey.shade50,
                  child: ListTile(
                    leading: const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    title: const Text('正在生成…'),
                    trailing: TextButton(
                      onPressed: () => ref.read(streamingProvider.notifier).cancel(effectiveTopic),
                      child: const Text('取消'),
                    ),
                  ),
                ),
              Expanded(
                child: messagesAsync.when(
                  data: (list) => ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    itemBuilder: (ctx, i) {
                      final m = list[i];
                      final isUser = m.role == 'user';
                      final contentText = m.model ?? '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            MessageBubble(
                              content: contentText,
                              isUser: isUser,
                              onCopy: () async {
                                await Clipboard.setData(ClipboardData(text: m.content));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('已复制')),
                                  );
                                }
                              },
                              onTranslate: () async {
                                final lang = await showModalBottomSheet<String>(
                                  context: context,
                                  builder: (_) => SafeArea(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
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
                                      ],
                                    ),
                                  ),
                                );
                                if (lang != null) {
                                  await ref.read(messageServiceProvider).translateMessage(
                                        messageId: m.id,
                                        lang: lang == 'zh' ? '中文' : 'English',
                                        ref: ref,
                                      );
                                  ref.invalidate(translationBlockProvider(m.id));
                                }
                              },
                              onRegenerate: !isUser
                                  ? () async {
                                      await ref
                                          .read(messageServiceProvider)
                                          .regenerateAssistant(
                                            assistantMessageId: m.id,
                                            topicId: effectiveTopic,
                                            ref: ref,
                                          );
                                      ref.invalidate(messageNotifierProvider(effectiveTopic));
                                    }
                                  : null,
                              onDelete: () async {
                                await ref.read(messageServiceProvider).deleteMessage(m.id);
                                ref.invalidate(messageNotifierProvider(effectiveTopic));
                              },
                            ),
                            Consumer(builder: (context, ref, _) {
                              final trans = ref.watch(translationBlockProvider(m.id));
                              return trans.when(
                                data: (b) => b == null
                                    ? const SizedBox.shrink()
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                          child: Align(
                                            alignment:
                                                isUser ? Alignment.centerRight : Alignment.centerLeft,
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxWidth:
                                                    MediaQuery.of(context).size.width * 0.75,
                                              ),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.1),
                                                border: Border.all(
                                                  color: Colors.green.withOpacity(0.3),
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                b.content,
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                loading: () => const SizedBox.shrink(),
                                error: (e, _) => const SizedBox.shrink(),
                              );
                            }),
                            Consumer(builder: (context, ref, _) {
                              final atts = ref.watch(attachmentsProvider(m.id));
                              return atts.when(
                                data: (list) => list.isEmpty
                                    ? const SizedBox.shrink()
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Column(
                                          crossAxisAlignment: isUser
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            for (final b in list)
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 4),
                                                child: AttachmentTile(block: b),
                                              ),
                                          ],
                                        ),
                                      ),
                                loading: () => const SizedBox.shrink(),
                                error: (e, _) => const SizedBox.shrink(),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('加载失败: $e')),
                ),
              ),
              MessageInput(
                topic: topic,
                assistant: currentAssistant,
                assistants: assistantList,
                isSending: isStreaming,
                onPause: () => ref.read(streamingProvider.notifier).cancel(effectiveTopic),
                onSubmit: (text, attachments, mentions) async {
                  final msgSvc = ref.read(messageServiceProvider);
                  await msgSvc.sendWithLlm(
                    topicId: topic.id,
                    text: text,
                    ref: ref,
                    attachments: attachments,
                    mentions: mentions,
                  );
                  ref.invalidate(messageNotifierProvider(topic.id));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
