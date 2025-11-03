import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/topic_provider.dart';
import '../../providers/assistant_provider.dart';
import '../../services/topic_service.dart';
import '../../models/topic.dart';
import '../../models/assistant.dart';
import '../../widgets/topic_item.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/search_input.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';

class TopicScreen extends ConsumerStatefulWidget {
  const TopicScreen({super.key});

  @override
  ConsumerState<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends ConsumerState<TopicScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TopicModel> _filter(List<TopicModel> topics) {
    if (_query.trim().isEmpty) return topics;
    final term = _query.trim().toLowerCase();
    return topics
        .where((topic) => topic.name.toLowerCase().contains(term))
        .toList();
  }

  Map<String, List<TopicModel>> _groupByDate(List<TopicModel> topics) {
    final now = DateTime.now();
    final groups = <String, List<TopicModel>>{};

    String getGroupKey(DateTime date) {
      final diff = now.difference(date);
      if (diff.inDays == 0) return '今天';
      if (diff.inDays == 1) return '昨天';
      if (diff.inDays < 7) return '本周';
      if (diff.inDays < 14) return '上周';
      if (diff.inDays < 30) return '本月';
      return '更早';
    }

    for (final topic in topics) {
      final date = DateTime.fromMillisecondsSinceEpoch(topic.updatedAt);
      final key = getGroupKey(date);
      groups.putIfAbsent(key, () => []).add(topic);
    }

    // 按时间顺序排序分组
    final orderedKeys = ['今天', '昨天', '本周', '上周', '本月', '更早'];
    final orderedGroups = <String, List<TopicModel>>{};
    for (final key in orderedKeys) {
      if (groups.containsKey(key)) {
        orderedGroups[key] = groups[key]!;
      }
    }

    return orderedGroups;
  }

  @override
  Widget build(BuildContext context) {
    final topicsAsync = ref.watch(topicNotifierProvider);
    final assistantsAsync = ref.watch(assistantsProvider);
    final topicService = ref.read(topicServiceProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Tokens.bgPrimaryDark
          : Tokens.bgPrimaryLight,
      body: topicsAsync.when(
        loading: () => const LoadingIndicator(message: '加载中...'),
        error: (error, stack) => ErrorView(
          message: '加载主题失败',
          details: error.toString(),
          onRetry: () => ref.invalidate(topicNotifierProvider),
        ),
        data: (topics) {
          final filtered = _filter(topics);
          final assistants = assistantsAsync.maybeWhen(
            data: (list) => {for (final a in list) a.id: a},
            orElse: () => <String, AssistantModel>{},
          );

          return Column(
            children: [
              // HeaderBar - 匹配原项目：px-4 h-[44px]
              HeaderBar(
                title: '最近主题',
                leftButton: HeaderBarButton(
                  icon: Icon(
                    Icons.menu,
                    size: 24,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Tokens.textPrimaryDark
                        : Tokens.textPrimaryLight,
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
                rightButton: HeaderBarButton(
                  icon: Icon(
                    Icons.add_comment_outlined,
                    size: 24,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Tokens.textPrimaryDark
                        : Tokens.textPrimaryLight,
                  ),
                  onPress: () async {
                    final assistants = assistantsAsync.maybeWhen(
                      data: (list) => list,
                      orElse: () => <AssistantModel>[],
                    );
                    final defaultAssistant = assistants.firstWhere(
                      (a) => a.id == 'default',
                      orElse: () => assistants.isNotEmpty
                          ? assistants.first
                          : AssistantModel(
                              id: 'default',
                              name: '默认助手',
                              prompt: '',
                              type: 'built_in',
                              emoji: '🤖',
                              createdAt: DateTime.now().millisecondsSinceEpoch,
                              updatedAt: DateTime.now().millisecondsSinceEpoch,
                            ),
                    );
                    final newTopic = await topicService.createTopic(
                      assistantId: defaultAssistant.id,
                      name: '新对话',
                    );
                    if (context.mounted) context.go('/home/chat/${newTopic.id}');
                  },
                ),
              ),
              // 搜索框和列表 - 匹配原项目：gap-[15px] px-5
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                      child: SearchInput(
                        placeholder: '搜索主题或助手',
                        controller: _searchController,
                        onChangeText: (value) => setState(() => _query = value),
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? (_query.isEmpty
                              ? EmptyState(
                                  icon: Icons.chat_bubble_outline,
                                  title: '暂无主题',
                                  description: '点击右上角按钮创建新的会话',
                                  actionLabel: '创建新主题',
                                  onAction: () async {
                                    final assistants = assistantsAsync.maybeWhen(
                                      data: (list) => list,
                                      orElse: () => <AssistantModel>[],
                                    );
                                    final defaultAssistant = assistants.firstWhere(
                                      (a) => a.id == 'default',
                                      orElse: () => assistants.isNotEmpty
                                          ? assistants.first
                                          : AssistantModel(
                                              id: 'default',
                                              name: '默认助手',
                                              prompt: '',
                                              type: 'built_in',
                                              emoji: '🤖',
                                              createdAt: DateTime.now().millisecondsSinceEpoch,
                                              updatedAt: DateTime.now().millisecondsSinceEpoch,
                                            ),
                                    );
                                    final newTopic = await topicService.createTopic(
                                      assistantId: defaultAssistant.id,
                                      name: '新对话',
                                    );
                                    if (context.mounted) {
                                      context.go('/home/chat/${newTopic.id}');
                                    }
                                  },
                                )
                              : _SearchEmptyState(query: _query))
                          : _buildTopicList(filtered, assistants, topicService),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopicList(
    List<TopicModel> topics,
    Map<String, AssistantModel> assistants,
    TopicService topicService,
  ) {
    final grouped = _groupByDate(topics);
    final sections = grouped.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: sections.fold<int>(0, (sum, entry) => sum + 1 + entry.value.length),
      itemBuilder: (context, index) {
        int offset = 0;
        for (final entry in sections) {
          if (index == offset) {
            return _SectionHeader(title: entry.key);
          }
          offset += 1;
          final topicsInGroup = entry.value;
          if (index < offset + topicsInGroup.length) {
            final topic = topicsInGroup[index - offset];
            final assistant = assistants[topic.assistantId];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TopicItem(
                topicId: topic.id,
                topicName: topic.name,
                assistantName: assistant?.name ?? '默认助手',
                assistantEmoji: assistant?.emoji ?? '🤖',
                updatedAt: topic.updatedAt,
                isActive: false,
                onTap: () async {
                  if (context.mounted) context.go('/home/chat/${topic.id}');
                },
                onRename: () => _renameTopic(context, topicService, topic),
                onDelete: () => _confirmDelete(context, topicService, topic.id),
              ),
            );
          }
          offset += topicsInGroup.length;
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _renameTopic(
    BuildContext context,
    TopicService service,
    TopicModel topic,
  ) async {
    final controller = TextEditingController(text: topic.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名主题'),
        content: TextField(
          controller: controller,
          maxLength: 30,
          decoration: const InputDecoration(hintText: '输入新的主题名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await service.updateTopic(topic.id, name: controller.text.trim());
      ref.invalidate(topicNotifierProvider);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TopicService service,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除主题'),
        content: const Text('删除后该主题及其消息不可恢复，确定删除？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await service.deleteTopic(id);
      ref.invalidate(topicNotifierProvider);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark
              ? Tokens.textPrimaryDark.withOpacity(0.65)
              : Tokens.textPrimaryLight.withOpacity(0.65),
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
              '未找到匹配的主题',
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
