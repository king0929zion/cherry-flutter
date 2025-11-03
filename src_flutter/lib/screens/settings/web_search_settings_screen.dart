import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/tokens.dart';
import '../../widgets/header_bar.dart';

class WebSearchSettingsScreen extends ConsumerWidget {
  const WebSearchSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HeaderBar(
              title: '网络搜索设置',
              leftButton: HeaderBarButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                ),
                onPress: () => context.pop(),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SettingGroup(
                    title: '搜索引擎',
                    children: [
                      _SettingTile(
                        icon: Icons.search,
                        label: 'Google',
                        trailing: const Icon(Icons.check, color: Tokens.green100),
                        onTap: () {},
                      ),
                      _SettingTile(
                        icon: Icons.search,
                        label: 'Bing',
                        onTap: () {},
                      ),
                      _SettingTile(
                        icon: Icons.search,
                        label: 'DuckDuckGo',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SettingGroup(
                    title: '搜索选项',
                    children: [
                      _SwitchTile(
                        icon: Icons.language,
                        label: '自动搜索',
                        value: true,
                        onChanged: (value) {},
                      ),
                      _SwitchTile(
                        icon: Icons.timer,
                        label: '实时搜索',
                        value: false,
                        onChanged: (value) {},
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
}

class _SettingGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _SettingGroup({
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8),
            child: Text(
              title!,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? Tokens.textPrimaryDark.withOpacity(0.7)
                    : Tokens.textPrimaryLight.withOpacity(0.7),
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Tokens.cardDark : Tokens.cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Column(
            children: _intersperse(children, const Divider(height: 1, thickness: 1)),
          ),
        ),
      ],
    );
  }

  List<Widget> _intersperse(List<Widget> list, Widget separator) {
    if (list.isEmpty) return [];
    final result = <Widget>[];
    for (int i = 0; i < list.length; i++) {
      result.add(list[i]);
      if (i < list.length - 1) {
        result.add(separator);
      }
    }
    return result;
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Tokens.green100,
          ),
        ],
      ),
    );
  }
}

