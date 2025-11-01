import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/topic_service.dart';
import '../../widgets/topic_item.dart';

/// TopicScreen - 主题列表页面
/// 带搜索、分组显示
class TopicScreen extends ConsumerStatefulWidget {
  const TopicScreen({super.key});

  @override
  ConsumerState<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends ConsumerState<TopicScreen> {
  final _searchController = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterTopics(List<dynamic> topics) {
    if (_searchText.isEmpty) return topics;
    return topics.where((t) {
      return t.name.toLowerCase().contains(_searchText.toLowerCase());
    }).toList();
  }

  Map<String, List<dynamic>> _groupTopics(List<dynamic> topics) {
    final now = DateTime.now();
    final groups = <String, List<dynamic>>{
      '今天': [],
      '昨天': [],
      '本周': [],
      '上周': [],
      '上月': [],
      '更早': [],
    };

    for (final topic in topics) {
      final date = DateTime.fromMillisecondsSinceEpoch(topic.updatedAt);
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        groups['今天']!.add(topic);
      } else if (diff.inDays == 1) {
        groups['昨天']!.add(topic);
      } else if (diff.inDays <= 7) {
        groups['本周']!.add(topic);
      } else if (diff.inDays <= 14) {
        groups['上周']!.add(topic);
      } else if (diff.inDays <= 30) {
        groups['上月']!.add(topic);
      } else {
        groups['更早']!.add(topic);
      }
    }

    // 移除空分组
    groups.removeWhere((key, value) => value.isEmpty);
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final topicsAsync = ref.watch(topicsProvider);
    final svc = ref.read(topicServiceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('最近主题'), // TODO: i18n
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () async {
              final t = await svc.createTopic();
              if (context.mounted) context.go('/home/chat/${t.id}');
            },
          ),
        ],
      ),
      body: topicsAsync.when(
        data: (list) {
          final filtered = _filterTopics(list);
          final grouped = _groupTopics(filtered);

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: theme.iconTheme.color?.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchText.isEmpty ? '暂无主题' : '未找到匹配的主题',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 搜索框
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索主题...', // TODO: i18n
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchText.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchText = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() => _searchText = value);
                  },
                ),
              ),

              // 主题列表
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: grouped.length * 2, // 标题 + 列表
                  itemBuilder: (ctx, i) {
                    final groupIndex = i ~/ 2;
                    final isHeader = i % 2 == 0;
                    final groupKey = grouped.keys.elementAt(groupIndex);
                    final groupTopics = grouped[groupKey]!;

                    if (isHeader) {
                      // 分组标题
                      return Padding(
                        padding: EdgeInsets.only(
                          top: groupIndex == 0 ? 0 : 20,
                          bottom: 10,
                        ),
                        child: Text(
                          groupKey,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      );
                    } else {
                      // 分组内容
                      return Column(
                        children: groupTopics.map((topic) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TopicItem(
                              topicId: topic.id,
                              topicName: topic.name,
                              assistantName: '默认助手', // TODO: 从助手获取
                              assistantEmoji: '🤖',
                              updatedAt: topic.updatedAt,
                              isActive: false,
                              onTap: () async {
                                await svc.setCurrentTopic(topic.id);
                                if (context.mounted) {
                                  context.go('/home/chat/${topic.id}');
                                }
                              },
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('删除主题'),
                                    content: const Text('确定要删除这个主题吗？'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('取消'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('删除'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await svc.deleteTopic(topic.id);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('加载失败: $e'),
            ],
          ),
        ),
      ),
    );
  }
}
