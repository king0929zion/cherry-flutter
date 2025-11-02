import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_settings.dart';
import '../../theme/tokens.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(userSettingsProvider);

    final groups = [
      _SettingGroupData(items: [
        _SettingItemData.profile(
          title: user.displayName,
          onTap: () => context.go('/settings/about/personal'),
          avatarBytes: user.avatarBytes,
        ),
      ]),
      _SettingGroupData(
        title: '模型与服务',
        items: [
          _SettingItemData(
            title: '供应商设置',
            icon: Icons.cloud_outlined,
            onTap: () => context.go('/settings/providers'),
          ),
          _SettingItemData(
            title: '助手设置',
            icon: Icons.inventory_2_outlined,
            onTap: () => context.go('/settings/assistant'),
          ),
          _SettingItemData(
            title: '网页搜索',
            icon: Icons.public_outlined,
            onTap: () => context.go('/settings/web-search'),
          ),
        ],
      ),
      _SettingGroupData(
        title: '设置',
        items: [
          _SettingItemData(
            title: '通用设置',
            icon: Icons.settings_outlined,
            onTap: () => context.go('/settings/general'),
          ),
          _SettingItemData(
            title: '数据管理',
            icon: Icons.storage_outlined,
            onTap: () => context.go('/settings/data-sources'),
          ),
        ],
      ),
      _SettingGroupData(
        title: '数据与安全',
        items: [
          _SettingItemData(
            title: '关于',
            icon: Icons.info_outline,
            onTap: () => context.go('/settings/about'),
          ),
        ],
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '设置',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '调整 Cherry Studio 的外观、模型与数据配置',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? Tokens.textSecondaryDark
                            : Tokens.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              SliverList.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return Padding(
                    padding: EdgeInsets.only(top: index == 0 ? 0 : 20),
                    child: _SettingGroup(
                      title: group.title,
                      items: group.items,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingGroupData {
  final String? title;
  final List<_SettingItemData> items;

  const _SettingGroupData({
    this.title,
    required this.items,
  });
}

class _SettingItemData {
  final String title;
  final IconData? icon;
  final VoidCallback onTap;
  final Uint8List? avatarBytes;

  const _SettingItemData({
    required this.title,
    this.icon,
    this.avatarBytes,
    required this.onTap,
  });

  factory _SettingItemData.profile({
    required String title,
    required VoidCallback onTap,
    Uint8List? avatarBytes,
  }) =>
      _SettingItemData(
        title: title,
        onTap: onTap,
        avatarBytes: avatarBytes,
      );

  bool get isProfile => icon == null;
}

class _SettingGroup extends StatelessWidget {
  final String? title;
  final List<_SettingItemData> items;
  final bool isDark;

  const _SettingGroup({
    required this.items,
    required this.isDark,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 10),
            child: Text(
              title!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1F25) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.25)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i != 0)
                  Divider(
                    height: 1,
                    indent: items[i].isProfile ? 20 : 72,
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.06),
                  ),
                _SettingTile(
                  data: items[i],
                  isDark: isDark,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final _SettingItemData data;
  final bool isDark;

  const _SettingTile({
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            _LeadingIcon(
              data: data,
              isDark: isDark,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                data.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark
                  ? Tokens.textSecondaryDark
                  : Tokens.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final _SettingItemData data;
  final bool isDark;

  const _LeadingIcon({
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isProfile) {
      final bytes = data.avatarBytes;
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF2A2E37), Color(0xFF202229)]
                : const [Color(0xFFF2F5F0), Color(0xFFE8EFE1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: ClipOval(
          child: bytes == null
              ? const Text('🍒', style: TextStyle(fontSize: 26))
              : Image.memory(
                  bytes,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? const Color(0xFF262A32) : const Color(0xFFF3F5F7),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.04),
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        data.icon,
        size: 22,
        color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
      ),
    );
  }
}
