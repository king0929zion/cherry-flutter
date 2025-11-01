import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// TopicItem - 主题列表项组件
/// 显示助手头像、名称、主题名、更新时间
class TopicItem extends StatelessWidget {
  final String topicId;
  final String topicName;
  final String assistantName;
  final String? assistantEmoji;
  final int updatedAt;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;

  const TopicItem({
    super.key,
    required this.topicId,
    required this.topicName,
    required this.assistantName,
    this.assistantEmoji,
    required this.updatedAt,
    this.isActive = false,
    required this.onTap,
    this.onDelete,
    this.onRename,
  });

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      // 今天 - 显示时间
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else {
      // 其他 - 显示日期
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '$month/$day';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isActive
        ? (isDark ? Tokens.greenDark10 : Tokens.green10)
        : Colors.transparent;

    return InkWell(
      onTap: onTap,
      onLongPress: onDelete != null || onRename != null
          ? () => _showContextMenu(context)
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 助手头像
            _buildAvatar(isDark),
            const SizedBox(width: 6),
            // 内容区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 助手名称 + 时间
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          assistantName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(updatedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // 主题名称
                  Text(
                    topicName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
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
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Tokens.brand.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF444444) : Colors.white,
          width: 3,
        ),
      ),
      child: Center(
        child: Text(
          assistantEmoji ?? '🤖',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onRename != null)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('重命名'),
                onTap: () {
                  Navigator.pop(ctx);
                  onRename?.call();
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('删除', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  onDelete?.call();
                },
              ),
          ],
        ),
      ),
    );
  }
}
