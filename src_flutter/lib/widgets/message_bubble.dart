import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'cherry_markdown.dart';
import 'tool_call_block.dart';
import '../models/tool_call.dart' as model;

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final VoidCallback? onCopy;
  final VoidCallback? onTranslate;
  final VoidCallback? onRegenerate;
  final VoidCallback? onDelete;
  final List<model.ToolCallBlock>? toolCalls;

  const MessageBubble({
    super.key,
    required this.content,
    required this.isUser,
    this.onCopy,
    this.onTranslate,
    this.onRegenerate,
    this.onDelete,
    this.toolCalls,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final maxWidth = MediaQuery.of(context).size.width * (isUser ? 0.72 : 0.85);

    final bubble = DecoratedBox(
      decoration: isUser ? _userDecoration(isDark) : _assistantDecoration(isDark),
      child: Padding(
        // 匹配原项目：px-5 (20px)
        padding: isUser
            ? const EdgeInsets.fromLTRB(20, 12, 20, 12) // px-5 py-3
            : const EdgeInsets.fromLTRB(0, 12, 0, 12), // px-0 (原项目助手消息px-0)
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CherryMarkdown(
              data: content,
              isUserBubble: isUser,
            ),
            if (toolCalls != null && toolCalls!.isNotEmpty)
              ToolCallList(toolCalls: toolCalls!),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: GestureDetector(
            onLongPress: () => _showContextMenu(context),
            child: bubble,
          ),
        ),
      ),
    );
  }

  BoxDecoration _userDecoration(bool isDark) {
    // 匹配原项目：bg-green-10 border border-green-20 rounded-l-xl rounded-tr-xl rounded-br-sm
    return BoxDecoration(
      color: isDark ? Tokens.greenDark10 : Tokens.green10,
      border: Border.all(
        color: isDark ? Tokens.greenDark20 : Tokens.green20,
        width: 1,
      ),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12), // rounded-l-xl = 12px
        topRight: Radius.circular(12), // rounded-tr-xl = 12px
        bottomRight: Radius.circular(2), // rounded-br-sm = 2px
        bottomLeft: Radius.circular(12), // rounded-l-xl = 12px
      ),
    );
  }

  BoxDecoration _assistantDecoration(bool isDark) {
    // 匹配原项目：rounded-2xl bg-transparent
    final background = isDark ? Tokens.cardDark : Tokens.cardLight;

    return BoxDecoration(
      color: background,
      borderRadius: const BorderRadius.all(
        Radius.circular(16), // rounded-2xl = 16px
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).dialogBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              if (onCopy != null)
                _ActionTile(
                  icon: Icons.copy_rounded,
                  label: '复制',
                  onTap: () {
                    Navigator.pop(ctx);
                    onCopy?.call();
                  },
                ),
              if (onTranslate != null)
                _ActionTile(
                  icon: Icons.translate_rounded,
                  label: '翻译',
                  onTap: () {
                    Navigator.pop(ctx);
                    onTranslate?.call();
                  },
                ),
              if (onRegenerate != null && !isUser)
                _ActionTile(
                  icon: Icons.refresh_rounded,
                  label: '重新生成',
                  onTap: () {
                    Navigator.pop(ctx);
                    onRegenerate?.call();
                  },
                ),
              if (onDelete != null)
                _ActionTile(
                  icon: Icons.delete_outline,
                  label: '删除',
                  destructive: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    onDelete?.call();
                  },
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final iconColor = destructive ? Tokens.textDelete : Theme.of(context).iconTheme.color;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: iconColor),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: destructive ? Tokens.textDelete : null,
            ),
      ),
      onTap: onTap,
    );
  }
}
