import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// MenuTabContent - 菜单标签内容组件
/// 匹配原项目：flex-1 gap-2.5 px-5 py-2.5
class MenuTabContent extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllPress;
  final Widget? child;

  const MenuTabContent({
    super.key,
    required this.title,
    this.onSeeAllPress,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行 - 匹配原项目：px-5 py-2.5 gap-2 items-center
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20), // px-5
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // justify-between
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10), // py-2.5
                child: Row(
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16, // text-base
                        color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (onSeeAllPress != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onSeeAllPress,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(10), // hitSlop
                      child: Text(
                        '查看全部',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Tokens.textLink, // text-text-link
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // 内容区域
        if (child != null) Expanded(child: child!),
      ],
    );
  }
}
