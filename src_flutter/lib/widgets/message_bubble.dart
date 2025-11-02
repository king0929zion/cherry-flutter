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
        padding: isUser
            ? const EdgeInsets.fromLTRB(20, 14, 20, 16)
            : const EdgeInsets.fromLTRB(20, 16, 20, 18),
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
    return BoxDecoration(
      color: isDark ? Tokens.greenDark10 : Tokens.green10,
      border: Border.all(
        color: isDark ? Tokens.greenDark20 : Tokens.green20,
      ),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(22),
        bottomLeft: Radius.circular(22),
        topRight: Radius.circular(22),
        bottomRight: Radius.circular(10),
      ),
      boxShadow: [
        BoxShadow(
          color: (isDark ? Colors.black : Tokens.green100).withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  BoxDecoration _assistantDecoration(bool isDark) {
    final borderColor =
        isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06);
    final background = isDark ? const Color(0xFF1A1C20) : Colors.white;

    return BoxDecoration(
      color: background,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(26),
        topRight: Radius.circular(26),
        bottomRight: Radius.circular(26),
        bottomLeft: Radius.circular(12),
      ),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
          blurRadius: 20,
          offset: const Offset(0, 12),
        ),
      ],
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
