import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/boxes.dart';
import '../../../services/topic_service.dart';
import '../../../theme/tokens.dart';

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
      child: Row(
        children: [
          // 左侧: 菜单按钮
          SizedBox(
            width: 40, // min-w-10
            child: IconButton(
              icon: const Icon(Icons.menu, size: 24),
              padding: EdgeInsets.zero,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          
          // 中间: 助手选择器(可展开,占据剩余空间)
          Expanded(
            child: Center(
              child: _AssistantSelection(topicId: topicId),
            ),
          ),
          
          // 右侧: 新建主题按钮
          SizedBox(
            width: 40, // min-w-10
            child: IconButton(
              icon: const Icon(Icons.add_comment_outlined, size: 24),
              padding: EdgeInsets.zero,
              onPressed: () async {
                final t = await ref.read(topicServiceProvider).createTopic();
                if (context.mounted) context.go('/home/chat/${t.id}');
              },
              tooltip: '新建主题', // TODO: i18n
            ),
          ),
        ],
      ),
    );
  }
}

/// AssistantSelection - 助手选择器组件
/// 显示助手名称和主题名称,点击可展开选择其他助手
class _AssistantSelection extends StatelessWidget {
  final String topicId;
  
  const _AssistantSelection({required this.topicId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 获取主题信息
    final topicData = Boxes.topics.get(topicId);
    if (topicData == null) {
      return const SizedBox.shrink();
    }
    
    final topic = Map<String, dynamic>.from(topicData as Map);
    final topicName = topic['name'] as String? ?? '新对话';
    
    // TODO: 获取助手信息
    final assistantName = '默认助手'; // 从 assistantId 获取
    
    return InkWell(
      onTap: () {
        // TODO: 显示助手选择器 BottomSheet
        _showAssistantSelector(context);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 助手名称
            Text(
              assistantName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2), // gap-0.5
            // 主题名称
            Text(
              topicName,
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
  
  void _showAssistantSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择助手', // TODO: i18n
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Tokens.brand.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('🤖', style: TextStyle(fontSize: 20)),
                  ),
                ),
                title: const Text('默认助手'),
                subtitle: const Text('通用对话助手'),
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: 切换助手
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/assistant');
                },
                child: const Text('查看全部助手'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
