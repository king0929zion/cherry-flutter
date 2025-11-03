import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/assistant_provider.dart';
import '../../models/assistant.dart';
import '../../theme/tokens.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/search_input.dart';
import '../../widgets/emoji_avatar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/app_shell.dart';
import '../../services/assistant_service.dart';

/// AssistantScreen - 助手列表页面
/// 匹配原项目：使用 HeaderBar、SearchInput，列表布局
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AssistantModel> _filter(List<AssistantModel> assistants) {
    if (_query.trim().isEmpty) return assistants;
    final term = _query.trim().toLowerCase();
    return assistants
        .where((assistant) =>
            assistant.name.toLowerCase().contains(term) ||
            (assistant.description?.toLowerCase().contains(term) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final assistantsAsync = ref.watch(assistantsProvider);

    return Scaffold(
      backgroundColor: isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // HeaderBar - 匹配原项目：title, leftButton (Menu), rightButtons (Store, Plus)
            HeaderBar(
              title: '我的助手',
              leftButton: HeaderBarButton(
                icon: Icon(
                  Icons.menu,
                  size: 24,
                  color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                ),
                onPress: () {
                  final shell = context.appShell;
                  if (shell != null) {
                    shell.openDrawer();
                  } else {
                    Scaffold.maybeOf(context)?.openDrawer();
                  }
                },
              ),
              rightButtons: [
                HeaderBarButton(
                  icon: Icon(
                    Icons.store_outlined,
                    size: 24,
                    color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                  ),
                  onPress: () => context.go('/assistant/market'),
                ),
                HeaderBarButton(
                  icon: Icon(
                    Icons.add,
                    size: 24,
                    color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                  ),
                  onPress: () async {
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
              ],
            ),
            // Container - 匹配原项目：p-0
            Expanded(
              child: assistantsAsync.when(
                loading: () => const LoadingIndicator(message: '加载中...'),
                error: (error, stack) => ErrorView(
                  message: '加载助手失败',
                  details: error.toString(),
                  onRetry: () => ref.invalidate(assistantsProvider),
                ),
                data: (assistants) {
                  final customAssistants = assistants.where((a) => a.type != 'built_in').toList();
                  final filtered = _filter(customAssistants);

                  return Column(
                    children: [
                      // SearchInput - 匹配原项目：px-4
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: SearchInput(
                          placeholder: '搜索助手',
                          controller: _searchController,
                          onChangeText: (value) => setState(() => _query = value),
                        ),
                      ),
                      const SizedBox(height: 8), // gap-2
                      // List - 匹配原项目：contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 30 }}
                      Expanded(
                        child: filtered.isEmpty
                            ? (_query.isEmpty
                                ? EmptyState(
                                    icon: Icons.person_outline,
                                    title: '暂无助手',
                                    description: '点击右上角 + 号创建新助手',
                                    actionLabel: '创建助手',
                                    onAction: () async {
                                      final service = ref.read(assistantServiceProvider);
                                      final newAssistant = await service.createAssistant(
                                        name: '新助手',
                                        prompt: '',
                                      );
                                      if (context.mounted) {
                                        context.go('/assistant/${newAssistant.id}');
                                      }
                                    },
                                  )
                                : _SearchEmptyState(query: _query))
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (ctx, i) => _AssistantItem(
                                  assistant: filtered[i],
                                  onTap: () => context.go('/assistant/${filtered[i].id}'),
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// AssistantItem - 匹配原项目的 AssistantItem
class _AssistantItem extends StatelessWidget {
  final AssistantModel assistant;
  final VoidCallback onTap;

  const _AssistantItem({
    required this.assistant,
    required this.onTap,
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? Tokens.cardDark : Tokens.cardLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Avatar - 匹配原项目
              EmojiAvatar(
                emoji: assistant.emoji ?? '🤖',
                size: 48,
                borderRadius: 12,
                borderWidth: 3,
                borderColor: isDark ? Tokens.greenDark20 : Tokens.green20,
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
                        fontSize: 16,
                      ),
                    ),
                    if (assistant.description != null && assistant.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          assistant.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isDark
                    ? Tokens.textSecondaryDark.withOpacity(0.9)
                    : Tokens.textSecondaryLight.withOpacity(0.9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  final String query;
  const _SearchEmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 64,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '未找到匹配的助手',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '搜索关键词: "$query"',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
