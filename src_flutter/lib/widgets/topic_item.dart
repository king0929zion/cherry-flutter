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
    }
    if (diff.inDays == 1) return '昨天';
    if (diff.inDays < 7) {
      const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      return weekdays[date.weekday % 7];
    }
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background =
        isActive ? (isDark ? Tokens.greenDark10 : Tokens.green10) : Colors.transparent;
    final borderColor =
        isActive ? (isDark ? Tokens.greenDark20 : Tokens.green20) : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        onLongPress: (onDelete != null || onRename != null) ? () => _showMenu(context) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: isActive ? 1.2 : 1),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: (isDark ? Tokens.greenDark100 : Tokens.green100).withOpacity(0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildLeading(isDark),
              const SizedBox(width: 12),
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
                              color: isDark
                                  ? Tokens.textPrimaryDark
                                  : Tokens.textPrimaryLight,
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.smart_toy_outlined,
                          size: 14,
                          color: isDark
                              ? Tokens.textSecondaryDark
                              : Tokens.textSecondaryLight,
                        ),
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
      ),
    );
  }

  Widget _buildLeading(bool isDark) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF273034), Color(0xFF1E2529)]
              : const [Color(0xFFF1F6EA), Color(0xFFE9EFE2)],
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF313B41) : Colors.white,
          width: 3,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        assistantEmoji ?? '🤖',
        style: const TextStyle(fontSize: 22),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet<void>(
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
                title: const Text('删除会话', style: TextStyle(color: Colors.red)),
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
