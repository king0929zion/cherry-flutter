import 'package:flutter/material.dart';

/// MenuTabContent - 菜单标签内容组件
/// 用于显示分组标题和"查看全部"按钮
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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.normal,
                ),
              ),
              if (onSeeAllPress != null)
                InkWell(
                  onTap: onSeeAllPress,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      '查看全部', // TODO: i18n
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF0090FF), // text-link
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
