import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/topic_service.dart';
import '../../services/assistant_service.dart';
import '../../widgets/topic_item.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/app_shell.dart';

class TopicScreen extends ConsumerStatefulWidget {
  const TopicScreen({super.key});

  @override
  ConsumerState<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends ConsumerState<TopicScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Topic> _filterTopics(List<Topic> topics) {
    if (_searchText.trim().isEmpty) return topics;
    final keyword = _searchText.trim().toLowerCase();
    return topics
        .where((topic) =>
            topic.name.toLowerCase().contains(keyword) ||
            topic.id.toLowerCase().contains(keyword))
        .toList();
  }

  Map<String, List<Topic>> _groupTopics(List<Topic> topics) {
    final now = DateTime.now();
    final groups = <String, List<Topic>>{
      '今天': [],
      '昨天': [],
      '本周': [],
      '上周': [],
      '更早': [],
    };

    for (final topic in topics) {
      final date = DateTime.fromMillisecondsSinceEpoch(topic.updatedAt);
      final diff = now.difference(date);
      final target = diff.inDays == 0
          ? '今天'
          : diff.inDays == 1
              ? '昨天'
              : diff.inDays < 7
                  ? '本周'
                  : diff.inDays < 14
                      ? '上周'
                      : '更早';
      groups[target]!.add(topic);
    }

    groups.removeWhere((_, value) => value.isEmpty);
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final topicsAsync = ref.watch(topicsProvider);
    final assistantsAsync = ref.watch(assistantsProvider);
    final topicService = ref.read(topicServiceProvider);
    final activeTopicId = topicService.currentTopicId;

    final assistantMap = assistantsAsync.maybeWhen(
      data: (list) => {for (final a in list) a.id: a},
      orElse: () => <String, Assistant>{},
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('最近主题'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            final shell = context.appShell;
            if (shell != null) {
              shell.openDrawer();
            } else {
              Scaffold.maybeOf(context)?.openDrawer();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () async {
              final newTopic = await topicService.createTopic();
              if (context.mounted) context.go('/home/chat/${newTopic.id}');
            },
          ),
        ],
      ),
      body: topicsAsync.when(
        data: (topics) {
          final filtered = _filterTopics(topics);
          if (filtered.isEmpty) {
            return _searchText.isEmpty
                ? EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: '暂无主题',
                    description: '点击右上角按钮创建第一条对话',
                    actionLabel: '创建新主题',
                    onAction: () async {
                      final newTopic = await topicService.createTopic();
                      if (context.mounted) context.go('/home/chat/${newTopic.id}');
                    },
                  )
                : SearchEmptyState(query: _searchText);
          }

          final grouped = _groupTopics(filtered);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索主题或助手…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchText.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchText = '');
                            },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchText = value),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final entry = grouped.entries.elementAt(index);
                    final topicsInGroup = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.7),
                                ),
                          ),
                        ),
                        ...topicsInGroup.map((topic) {
                          final assistant = assistantMap[topic.assistantId];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TopicItem(
                              topicId: topic.id,
                              topicName: topic.name,
                              assistantName: assistant?.name ?? '默认助手',
                              assistantEmoji: assistant?.emoji ?? '🤖',
                              updatedAt: topic.updatedAt,
                              isActive: topic.id == activeTopicId,
                              onTap: () async {
                                await topicService.setCurrentTopic(topic.id);
                                if (context.mounted) {
                                  context.go('/home/chat/${topic.id}');
                                }
                              },
                              onRename: () => _showRenameDialog(context, topicService, topic),
                              onDelete: () => _confirmDelete(context, topicService, topic.id),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingIndicator(message: '加载中...'),
        error: (err, _) => ErrorView(
          message: '加载主题失败',
          details: err.toString(),
          onRetry: () => ref.invalidate(topicsProvider),
        ),
      ),
    );
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    TopicService topicService,
    Topic topic,
  ) async {
    final controller = TextEditingController(text: topic.name);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名主题'),
        content: TextField(
          controller: controller,
          maxLength: 30,
          decoration: const InputDecoration(hintText: '输入新的主题名称'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result == true) {
      await topicService.renameTopic(topic.id, controller.text.trim());
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TopicService topicService,
    String topicId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除主题'),
        content: const Text('删除后该主题及其消息不可恢复，确定删除？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await topicService.deleteTopic(topicId);
    }
  }
}
