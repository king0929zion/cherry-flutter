import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_settings.dart';
import '../../theme/tokens.dart';
import '../../i18n/app_localizations.dart';

/// HeaderBar - 匹配原项目的HeaderBar组件
class _HeaderBar extends StatelessWidget {
  final String title;

  const _HeaderBar({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // 匹配原项目：px-4 items-center h-[44px] justify-between
    return Container(
      height: 44, // h-[44px]
      padding: const EdgeInsets.symmetric(horizontal: 16), // px-4
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // justify-between
        crossAxisAlignment: CrossAxisAlignment.center, // items-center
        children: [
          // Left area - min-w-[40px]
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 24),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          // Title - text-[18px] font-bold text-center
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18, // text-[18px]
                fontWeight: FontWeight.bold, // font-bold
                color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
              ),
            ),
          ),
          // Right area - min-w-[40px]
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

const double _kTileHPadding = 16;
const double _kTileVPadding = 14;
const double _kIconGap = 12;
const double _kIconBoxSize = 32;
const double _kProfileAvatarSize = 48;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(userSettingsProvider);
    final displayName =
        user.displayName.trim().isEmpty ? l10n.personalSettings : user.displayName.trim();

    final groups = [
      _SettingGroupData(items: [
        _SettingItemData.profile(
          title: displayName,
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
            title: '模型管理',
            icon: Icons.smart_toy_outlined,
            onTap: () => context.go('/settings/models'),
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

    // 匹配原项目：SafeAreaContainer Container gap-6
    return Scaffold(
      backgroundColor: isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight,
      body: SafeArea(
        child: Column(
          children: [
            // HeaderBar - 匹配原项目：px-4 h-[44px]
            _HeaderBar(title: l10n.settings),
            // Container - 匹配原项目：flex-1 p-4 gap-5
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16), // p-4
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return Padding(
                            padding: EdgeInsets.only(top: index == 0 ? 0 : 24), // gap-6 = 24px
                            child: _SettingGroup(
                              title: group.title,
                              items: group.items,
                              isDark: isDark,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
    // 匹配原项目：gap-2
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // GroupTitle - 匹配原项目：font-bold opacity-70 pl-3
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8), // pl-3 gap-2
            child: Text(
              title!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: (isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight)
                    .withOpacity(0.7),
              ),
            ),
          ),
        // Group - 匹配原项目：rounded-xl bg-ui-card-background overflow-hidden
        ClipRRect(
          borderRadius: BorderRadius.circular(12), // rounded-xl = 12px
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark ? Tokens.cardDark : Tokens.cardLight, // bg-ui-card-background
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i != 0)
                    Divider(
                      height: 1,
                      indent: _kTileHPadding +
                          (items[i].isProfile ? _kProfileAvatarSize : _kIconBoxSize) +
                          _kIconGap,
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
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
    // 匹配原项目：PressableRow py-[14px] px-4 justify-between items-center
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(12), // rounded-xl
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16, // px-4
            vertical: 14, // py-[14px]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // justify-between
            crossAxisAlignment: CrossAxisAlignment.center, // items-center
            children: [
              Row(
                children: [
                  _LeadingIcon(
                    data: data,
                    isDark: isDark,
                  ),
                  const SizedBox(width: _kIconGap), // gap-3 = 12px
                  Text(
                    data.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, // font-bold
                      color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              // RowRightArrow - 匹配原项目：ChevronRight size={20} text-text-secondary opacity-90
              Icon(
                Icons.chevron_right,
                size: 20,
                color: (isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight)
                    .withOpacity(0.9),
              ),
            ],
          ),
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
        width: _kProfileAvatarSize,
        height: _kProfileAvatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF2B3038), Color(0xFF1F2229)]
                : const [Color(0xFFF3F6F0), Color(0xFFE7EEE2)],
          ),
        ),
        alignment: Alignment.center,
        child: ClipOval(
          child: bytes == null
              ? const Text('🍒', style: TextStyle(fontSize: 24))
              : Image.memory(
                  bytes,
                  width: _kProfileAvatarSize - 6,
                  height: _kProfileAvatarSize - 6,
                  fit: BoxFit.cover,
                ),
        ),
      );
    }

    return SizedBox(
      width: _kIconBoxSize,
      height: _kIconBoxSize,
      child: Icon(
        data.icon!,
        size: 24,
        color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
      ),
    );
  }
}
