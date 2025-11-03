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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final assistants = ref.watch(customAssistantsProvider);
    final TextEditingController searchController = TextEditingController();
    String searchText = '';
    
    // 匹配原项目：SafeAreaContainer pb-0 Container p-0
    return Scaffold(
      backgroundColor: isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight,
      body: SafeArea(
        child: Column(
          children: [
            // HeaderBar - 匹配原项目
            _HeaderBar(
              title: '我的助手',
              onMenuPress: () {
                Scaffold.maybeOf(context)?.openDrawer();
              },
              onMarketPress: () => context.go('/assistant/market'),
              onAddPress: () async {
                final service = ref.read(assistantServiceProvider);
                final newAssistant = await service.createAssistant(
                  name: '新助手',
                  prompt: '',
                );
                if (context.mounted) {
                  context.go('/assistant/${newAssistant.id}');
                }
              },
            ),
            // Container - 匹配原项目：p-0
            Expanded(
              child: Padding(
                padding: EdgeInsets.zero, // p-0
                child: Column(
                  children: [
                    // SearchInput - 匹配原项目：px-4
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16), // px-4
                      child: _buildSearchField(context, searchController, (value) {
                        searchText = value;
                      }),
                    ),
                    const SizedBox(height: 8), // h-2 = 8px
                    // List - 匹配原项目：contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 30 }}
                    Expanded(
                      child: assistants.isEmpty
                          ? Center(
                              child: Text(
                                '暂无助手',
                                style: theme.textTheme.bodyMedium,
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 30), // paddingHorizontal: 16, paddingBottom: 30
                              itemCount: assistants.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8), // h-2
                              itemBuilder: (ctx, i) => _AssistantItem(
                                assistant: assistants[i],
                                onTap: () => context.go('/assistant/${assistants[i].id}'),
                                onPress: () {
                                  // Show bottom sheet
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, TextEditingController controller, ValueChanged<String> onChanged) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Tokens.cardDark : Tokens.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 16,
          color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
          ),
          hintText: '搜索...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}

/// HeaderBar - 匹配原项目的HeaderBar组件
class _HeaderBar extends StatelessWidget {
  final String title;
  final VoidCallback onMenuPress;
  final VoidCallback onMarketPress;
  final VoidCallback onAddPress;

  const _HeaderBar({
    required this.title,
    required this.onMenuPress,
    required this.onMarketPress,
    required this.onAddPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.menu, size: 24),
              onPressed: onMenuPress,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.store_outlined, size: 24),
                onPressed: onMarketPress,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 24),
                onPressed: onAddPress,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// AssistantItem - 匹配原项目的AssistantItem
class _AssistantItem extends StatelessWidget {
  final AssistantModel assistant;
  final VoidCallback onTap;
  final VoidCallback onPress;

  const _AssistantItem({
    required this.assistant,
    required this.onTap,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? Tokens.greenDark20 : Tokens.green10,
                ),
                alignment: Alignment.center,
                child: Text(
                  assistant.emoji ?? '🤖',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assistant.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (assistant.description != null && assistant.description!.isNotEmpty)
                      Text(
                        assistant.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
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
