import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/assistant_provider.dart';
import '../../models/assistant.dart';
import '../../theme/tokens.dart';
import '../../widgets/emoji_avatar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/animated_widgets.dart';

/// AssistantScreen - 助手列表页面
/// 卡片网格布局，展示所有助手
class AssistantScreen extends ConsumerWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assistants = ref.watch(assistantNotifierProvider);
    final svc = ref.read(assistantServiceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的助手'), // TODO: i18n
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await ref.read(assistantNotifierProvider.notifier).createAssistant(
                    name: '新助手',
                    prompt: '',
                  );
            },
          ),
        ],
      ),
      body: assistants.when(
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.smart_toy_outlined,
              title: '暂无助手',
              description: '创建你的第一个 AI 助手',
              actionLabel: '创建助手',
              onAction: () async {
                await ref.read(assistantNotifierProvider.notifier).createAssistant(
                      name: '新助手',
                      prompt: '',
                    );
              },
            );
          }
          
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: list.length,
            itemBuilder: (ctx, i) => _AssistantCard(
              assistant: list[i],
              onTap: () => context.go('/assistant/${list[i].id}'),
            ),
          );
        },
        loading: () => const LoadingIndicator(message: '加载助手...'),
        error: (e, _) => ErrorView(
          message: '加载助手失败',
          details: e.toString(),
          onRetry: () => ref.invalidate(assistantNotifierProvider),
        ),
      ),
    );
  }
}

/// AssistantCard - 助手卡片组件
class _AssistantCard extends StatelessWidget {
  final AssistantModel assistant;
  final VoidCallback onTap;

  const _AssistantCard({
    required this.assistant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.cardColor,
                theme.cardColor.withOpacity(0.95),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 头像
              EmojiAvatar(
                emoji: assistant.emoji ?? '🤖',
                size: 80,
                borderRadius: 20,
                borderWidth: 4,
                borderColor: isDark 
                  ? const Color(0xFF333333)
                  : const Color(0xFFF7F7F7),
              ),
              
              const SizedBox(height: 12),
              
              // 名称
              Text(
                assistant.name,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // 描述
              Expanded(
                child: Text(
                  assistant.prompt ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // 底部标签（如果有）
              if (assistant.tags != null && assistant.tags!.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: assistant.tags!
                      .take(2)
                      .map((tag) => _buildTag(tag, isDark))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTag(String tag, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? Tokens.greenDark10 : Tokens.green10,
        border: Border.all(
          color: isDark ? Tokens.greenDark20 : Tokens.green20,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 10,
          color: isDark ? Tokens.greenDark100 : Tokens.green100,
        ),
      ),
    );
  }
}
