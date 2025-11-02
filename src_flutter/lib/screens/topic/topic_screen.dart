import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/topic_service.dart';
import '../../services/assistant_service.dart';
import '../../models/topic.dart';
import '../../models/assistant.dart';
import '../../widgets/topic_item.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
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
        .where((topic) =>
            topic.name.toLowerCase().contains(term) || topic.id.toLowerCase().contains(term))
        .toList();
  }

  Map<String, List<TopicModel>> _groupByDate(List<TopicModel> topics) {
    final now = DateTime.now();
    final groups = <String, List<TopicModel>>{
      '今天': [],
      '昨天': [],
      '本周': [],
      '上周': [],
      '更早': [],
    };

    void add(String key, TopicModel topic) {
      groups[key] ??= [];
      groups[key]!.add(topic);
    }

    for (final topic in topics) {
      final date = DateTime.fromMillisecondsSinceEpoch(topic.updatedAt);
      final diff = now.difference(date);
      if (diff.inDays == 0) {
        add('今天', topic);
      } else if (diff.inDays == 1) {
        add('昨天', topic);
      } else if (diff.inDays < 7) {
        add('本周', topic);
      } else if (diff.inDays < 14) {
        add('上周', topic);
      } else {
        add('更早', topic);
      }
    }

    groups.removeWhere((key, value) => value.isEmpty);
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final topicsAsync = ref.watch(topicsProvider);
    final assistantsAsync = ref.watch(assistantsProvider);
    final topicService = ref.read(topicServiceProvider);

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
              final newTopic = await topicService.createTopic(assistantId: 'default', name: '新对话');
              if (context.mounted) context.go('/home/chat/${newTopic.id}');
            },
          ),
        ],
      ),
      body: topicsAsync.when(
        loading: () => const LoadingIndicator(message: '加载中...'),
        error: (error, stack) => ErrorView(
          message: '加载主题失败',
          details: error.toString(),
          onRetry: () => ref.invalidate(topicsProvider),
        ),
            data: (topics) {
          final filtered = _filter(topics);
          if (filtered.isEmpty) {
            if (_query.isEmpty) {
              return EmptyState(
                icon: Icons.chat_bubble_outline,
                title: '暂无主题',
                description: '点击右上角按钮创建新的会话',
                actionLabel: '创建新主题',
                onAction: () async {
                  final newTopic = await topicService.createTopic();
                  if (context.mounted) context.go('/home/chat/${newTopic.id}');
                },
              );
            }
            return SearchEmptyState(query: _query);
          }

          final grouped = _groupByDate(filtered);
          final assistants = assistantsAsync.maybeWhen(
            data: (list) => {for (final a in list) a.id: a},
            orElse: () => <String, AssistantModel>{},
          );

          final sections = grouped.entries.toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: _SearchField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Expanded(
                child: ListView.builder(
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _renameTopic(BuildContext context, TopicService service, TopicModel topic) async {
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('保存')),
        ],
      ),
    );
    if (confirmed == true) {
      await service.updateTopic(topic.id, name: controller.text.trim());
    }
  }

  Future<void> _confirmDelete(BuildContext context, TopicService service, String id) async {
    final confirmed = await showDialog<bool>(
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
    if (confirmed == true) {
      await service.deleteTopic(id);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.65),
            ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, size: 18),
        hintText: '搜索主题或助手',
        isDense: true,
        filled: true,
        fillColor: isDark ? const Color(0xFF1B1F26) : const Color(0xFFF4F5F7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}
