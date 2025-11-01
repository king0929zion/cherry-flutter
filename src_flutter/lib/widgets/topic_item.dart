import 'package:flutter/material.dart';

import '../theme/tokens.dart';

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
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 7) {
      const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
      return weekdays[date.weekday % 7];
    } else {
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '$month/$day';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = isActive
        ? (isDark ? Tokens.greenDark20 : Tokens.green10)
        : (isDark ? const Color(0xFF18181C) : Colors.white);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      onLongPress: (onDelete != null || onRename != null)
          ? () => _showContextMenu(context)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? (isDark ? Tokens.greenDark100 : Tokens.green100)
                : (isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.05)),
            width: isActive ? 1.4 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: (isDark ? Tokens.greenDark100 : Tokens.green100)
                        .withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 12),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatar(isDark),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          topicName.isEmpty ? '未命名会话' : topicName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(updatedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Tokens.textSecondaryDark
                              : Tokens.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.smart_toy_outlined,
                          size: 14,
                          color: isDark
                              ? Tokens.textSecondaryDark
                              : Tokens.textSecondaryLight),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          assistantName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? Tokens.textSecondaryDark
                                : Tokens.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1F2A28), const Color(0xFF16211F)]
              : [const Color(0xFFE6F4EC), const Color(0xFFFFFFFF)],
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF2F3A38) : Colors.white,
          width: 3,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        assistantEmoji ?? '🤖',
        style: const TextStyle(fontSize: 24),
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
                leading: const Icon(Icons.edit_outlined),
                title: const Text('重命名'),
                onTap: () {
                  Navigator.pop(ctx);
                  onRename?.call();
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title:
                    const Text('删除会话', style: TextStyle(color: Colors.red)),
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
