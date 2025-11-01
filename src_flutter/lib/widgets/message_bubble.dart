import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../theme/tokens.dart';

/// MessageBubble - 消息气泡组件
/// 完全复刻原项目的样式:
/// - 用户消息: 右对齐,绿色背景,圆角(左+右上圆,右下小圆)
/// - 助手消息: 左对齐,透明背景,完全圆角
class MessageBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final VoidCallback? onLongPress;
  final VoidCallback? onCopy;
  final VoidCallback? onTranslate;
  final VoidCallback? onRegenerate;
  final VoidCallback? onDelete;

  const MessageBubble({
    super.key,
    required this.content,
    required this.isUser,
    this.onLongPress,
    this.onCopy,
    this.onTranslate,
    this.onRegenerate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isUser) {
      // 用户消息 - 右对齐,绿色背景
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14), // px-[14px]
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onLongPress: () => _showContextMenu(context),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // px-5
              decoration: BoxDecoration(
                color: isDark ? Tokens.greenDark10 : Tokens.green10,
                border: Border.all(
                  color: isDark ? Tokens.greenDark20 : Tokens.green20,
                  width: 1,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), // rounded-l-xl
                  bottomLeft: Radius.circular(12),
                  topRight: Radius.circular(12), // rounded-tr-xl
                  bottomRight: Radius.circular(4), // rounded-br-sm
                ),
              ),
              child: _buildContent(context, isDark),
            ),
          ),
        ),
      );
    } else {
      // 助手消息 - 左对齐,透明背景
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14), // px-[14px]
        child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onLongPress: () => _showContextMenu(context),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85,
              ),
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(16)), // rounded-2xl
              ),
              child: _buildContent(context, isDark),
            ),
          ),
        ),
      );
    }
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onCopy != null)
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('复制'), // TODO: i18n
                onTap: () {
                  Navigator.pop(ctx);
                  onCopy?.call();
                },
              ),
            if (onTranslate != null)
              ListTile(
                leading: const Icon(Icons.translate),
                title: const Text('翻译'), // TODO: i18n
                onTap: () {
                  Navigator.pop(ctx);
                  onTranslate?.call();
                },
              ),
            if (onRegenerate != null && !isUser)
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('重新生成'), // TODO: i18n
                onTap: () {
                  Navigator.pop(ctx);
                  onRegenerate?.call();
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

  Widget _buildContent(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        // 段落样式
        p: theme.textTheme.bodyMedium?.copyWith(
          height: 1.6,
          color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
        ),
        
        // 标题样式
        h1: theme.textTheme.headlineMedium?.copyWith(
          color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
          fontWeight: FontWeight.bold,
        ),
        h2: theme.textTheme.titleLarge?.copyWith(
          color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
          fontWeight: FontWeight.bold,
        ),
        h3: theme.textTheme.titleMedium?.copyWith(
          color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
        
        // 代码块样式
        code: TextStyle(
          backgroundColor: isDark 
            ? const Color(0xFF2D2D2D)
            : const Color(0xFFF5F5F5),
          color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
          fontFamily: 'monospace',
          fontSize: 13,
        ),
        codeblockPadding: const EdgeInsets.all(12),
        codeblockDecoration: BoxDecoration(
          color: isDark 
            ? const Color(0xFF1E1E1E)
            : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Tokens.gray20 : Tokens.gray10,
            width: 1,
          ),
        ),
        
        // 引用块样式
        blockquote: theme.textTheme.bodyMedium?.copyWith(
          color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
          fontStyle: FontStyle.italic,
        ),
        blockquotePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Tokens.brand,
              width: 4,
            ),
          ),
          color: isDark ? Tokens.gray10 : Tokens.gray10.withOpacity(0.3),
        ),
        
        // 链接样式
        a: TextStyle(
          color: Tokens.textLink,
          decoration: TextDecoration.underline,
        ),
        
        // 列表样式
        listBullet: theme.textTheme.bodyMedium?.copyWith(
          color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
        ),
        
        // 表格样式
        tableBorder: TableBorder.all(
          color: isDark ? Tokens.gray20 : Tokens.gray10,
          width: 1,
        ),
        tableHead: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
        ),
        tableBody: theme.textTheme.bodyMedium?.copyWith(
          color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
        ),
        
        // 其他
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? Tokens.gray20 : Tokens.gray10,
              width: 1,
            ),
          ),
        ),
        
        strong: const TextStyle(fontWeight: FontWeight.bold),
        em: const TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }
}
