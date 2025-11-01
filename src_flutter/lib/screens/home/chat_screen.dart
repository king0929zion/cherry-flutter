import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../providers/app_state.dart';
import '../../providers/provider_settings.dart';
import '../../services/message_service.dart';
import '../../services/topic_service.dart';
import '../../widgets/message_input.dart';
import '../../widgets/message_bubble.dart';
import '../../services/block_service.dart';
import '../../models/block.dart';
import 'widgets/attachment_tile.dart';
import '../../providers/streaming.dart';
import 'widgets/chat_header.dart';

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
    final streamingMap = ref.watch(streamingProvider);
    final isStreaming = streamingMap.containsKey(effectiveTopic);
    
    return Scaffold(
      appBar: ChatHeader(topicId: effectiveTopic),
      body: Column(
        children: [
          if (cfg.apiKey.isEmpty)
            Material(
              color: Colors.amber.shade100,
              child: const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('请先在 设置 -> 供应商 设置 OpenAI API Key 才能调用模型'),
              ),
            ),
          if (isStreaming)
            Material(
              color: Colors.blueGrey.shade50,
              child: ListTile(
                leading: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                title: const Text('正在生成…'),
                trailing: TextButton(
                  onPressed: () => ref.read(streamingProvider.notifier).cancel(effectiveTopic),
                  child: const Text('取消'),
                ),
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          // 主消息气泡
                          MessageBubble(
                            content: m.content,
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
                              // 显示语言选择
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
                                    await ref.read(messageServiceProvider).regenerateAssistant(
                                          assistantMessageId: m.id,
                                          topicId: effectiveTopic,
                                          ref: ref,
                                        );
                                    ref.invalidate(messagesProvider(effectiveTopic));
                                  }
                                : null,
                            onDelete: () async {
                              await ref.read(messageServiceProvider).deleteMessage(m.id);
                              ref.invalidate(messagesProvider(effectiveTopic));
                            },
                          ),
                          
                          // 翻译块
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
                                          alignment: isUser
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          child: Container(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context).size.width * 0.75,
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
                          
                          // 附件
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
            MessageInput(onSubmit: (text, attachments) async {
              final msgSvc = ref.read(messageServiceProvider);
              final topicSvc = ref.read(topicServiceProvider);
              // Ensure topic exists and set current if default route
              String tid = effectiveTopic;
              await msgSvc.sendWithLlm(topicId: tid, text: text, ref: ref, attachments: attachments);
              // refresh
              ref.invalidate(messagesProvider(tid));
            }),
        ],
      ),
    );
  }
}
