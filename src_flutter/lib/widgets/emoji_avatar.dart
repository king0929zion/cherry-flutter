import 'package:flutter/material.dart';

/// EmojiAvatar - Emoji 头像组件
/// 用于助手、主题等的头像显示
class EmojiAvatar extends StatelessWidget {
  final String emoji;
  final double size;
  final double borderRadius;
  final double borderWidth;
  final Color? borderColor;
  final Color? backgroundColor;

  const EmojiAvatar({
    super.key,
    required this.emoji,
    this.size = 42,
    this.borderRadius = 16,
    this.borderWidth = 3,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // 默认边框颜色
    final effectiveBorderColor = borderColor ?? 
        (isDark ? const Color(0xFF444444) : const Color(0xFFEEEEEE));
    
    // 默认背景颜色
    final effectiveBackgroundColor = backgroundColor ?? 
        theme.colorScheme.primary.withOpacity(0.1);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: size * 0.45, // emoji 大小约为容器的 45%
          ),
        ),
      ),
    );
  }
}
