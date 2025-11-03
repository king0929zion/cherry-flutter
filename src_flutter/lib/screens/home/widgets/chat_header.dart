import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/topic_provider.dart';
import '../../../providers/assistant_provider.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/app_shell.dart';
import '../../../models/topic.dart';
import '../../../models/assistant.dart';

/// ChatHeader - 聊天页面头部
/// 完全复刻原项目的布局:
/// - 左侧: 菜单按钮(打开抽屉)
/// - 中间: 助手选择器(助手名称 + 主题名称)
/// - 右侧: 新建主题按钮
class ChatHeader extends ConsumerWidget implements PreferredSizeWidget {
  final String topicId;
  
  const ChatHeader({super.key, required this.topicId});

  @override
  Size get preferredSize => const Size.fromHeight(44); // h-11 = 44px

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final topicAsync = ref.watch(topicProvider(topicId));
    final assistantsAsync = ref.watch(assistantsProvider);
    
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14), // px-3.5
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: topicAsync.when(
        data: (topic) {
          final assistantAsync = ref.watch(assistantProvider(topic.assistantId));
          return assistantAsync.when(
            data: (assistant) {
              if (assistant == null) {
                return const SizedBox.shrink();
              }
              return Row(
                children: [
                  // 左侧: 菜单按钮
                  SizedBox(
                    width: 40, // min-w-10
                    child: IconButton(
                      icon: const Icon(Icons.menu, size: 24),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        final shell = context.appShell;
                        if (shell != null) {
                          shell.openDrawer();
                        } else {
                          Scaffold.maybeOf(context)?.openDrawer();
                        }
                      },
                    ),
                  ),
                  
                  // 中间: 助手选择器(可展开,占据剩余空间)
                  Expanded(
                    child: Center(
                      child: _AssistantSelection(
                        topic: topic,
                        assistant: assistant,
                        assistantsAsync: assistantsAsync,
                      ),
                    ),
                  ),
                  
                  // 右侧: 新建主题按钮
                  SizedBox(
                    width: 40, // min-w-10
                    child: IconButton(
                      icon: const Icon(Icons.add_comment_outlined, size: 24),
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        final assistants = assistantsAsync.maybeWhen(
                          data: (list) => list,
                          orElse: () => <AssistantModel>[],
                        );
                        final defaultAssistant = assistants.isNotEmpty 
                          ? assistants.first 
                          : AssistantModel(
                              id: 'default',
                              name: '默认助手',
                              prompt: '',
                              type: 'built_in',
                              createdAt: DateTime.now().millisecondsSinceEpoch,
                              updatedAt: DateTime.now().millisecondsSinceEpoch,
                            );
                        final t = await ref.read(topicServiceProvider).createTopic(
                              assistantId: defaultAssistant.id,
                              name: '新对话',
                            );
                        if (context.mounted) context.go('/home/chat/${t.id}');
                      },
                      tooltip: '新建主题',
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

/// AssistantSelection - 助手选择器组件
/// 显示助手名称和主题名称,点击可展开选择其他助手
class _AssistantSelection extends ConsumerWidget {
  final TopicModel topic;
  final AssistantModel assistant;
  final AsyncValue<List<AssistantModel>> assistantsAsync;
  
  const _AssistantSelection({
    required this.topic,
    required this.assistant,
    required this.assistantsAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => _showAssistantSelector(context, ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 助手名称
            Text(
              assistant.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.normal,
                color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2), // gap-0.5
            // 主题名称
            Text(
              topic.name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: Tokens.gray60,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAssistantSelector(BuildContext context, WidgetRef ref) {
    final assistants = assistantsAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <AssistantModel>[],
    );
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '选择助手',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: assistants.length + 1,
                  itemBuilder: (ctx, index) {
                    if (index == assistants.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.go('/assistant');
                          },
                          child: const Text('查看全部助手'),
                        ),
                      );
                    }
                    final item = assistants[index];
                    final isSelected = item.id == assistant.id;
                    return ListTile(
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Tokens.brand.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            item.emoji ?? '🤖',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      title: Text(item.name),
                      subtitle: item.description != null ? Text(item.description!) : null,
                      trailing: isSelected 
                        ? Icon(Icons.check, color: Tokens.brand)
                        : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        if (item.id != assistant.id) {
                          ref.read(topicServiceProvider).updateTopic(
                            topic.id,
                            assistantId: item.id,
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
