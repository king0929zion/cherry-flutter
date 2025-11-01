import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/tokens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _ProfileCard(
            onTap: () => context.go('/settings/about/personal'),
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            icon: Icons.dashboard_customize_outlined,
            title: '模型与服务',
            subtitle: '配置供应商、助手和 Web 搜索选项。',
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            items: [
              _SettingTile(
                icon: Icons.cloud_outlined,
                title: '供应商设置',
                subtitle: '配置 API 端点、密钥和模型',
                onTap: () => context.go('/settings/providers'),
              ),
              _SettingTile(
                icon: Icons.smart_toy_outlined,
                title: '助手设置',
                subtitle: '绑定默认/快速/翻译助手',
                onTap: () => context.go('/settings/assistant'),
              ),
              _SettingTile(
                icon: Icons.public_outlined,
                title: '网页搜索',
                subtitle: '配置搜索引擎和模板',
                onTap: () => context.go('/settings/web-search'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _SectionHeader(
            icon: Icons.tune_outlined,
            title: '通用',
            subtitle: '控制外观、语言和数据管理。',
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            items: [
              _SettingTile(
                icon: Icons.settings_outlined,
                title: '通用设置',
                subtitle: '主题模式、语言、备份',
                onTap: () => context.go('/settings/general'),
              ),
              _SettingTile(
                icon: Icons.storage_outlined,
                title: '数据管理',
                subtitle: '导入导出、清除数据',
                onTap: () => context.go('/settings/data-sources'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _SectionHeader(
            icon: Icons.info_outline,
            title: '关于',
            subtitle: '版本信息、开源许可等内容。',
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            items: [
              _SettingTile(
                icon: Icons.info_outline,
                title: '关于',
                subtitle: '查看版本号与开源信息',
                onTap: () => context.go('/settings/about'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '所有设置均存储在本地 Hive 数据库中，不会上传到服务器。'
                '\n如需在多设备间迁移，可使用“通用设置 > 数据导出/导入”功能。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ProfileCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Tokens.brand,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: const Text(
            'C',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          'Cherry Studio',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('查看个人信息与协议'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: (isDark ? Tokens.bgSecondaryDark : Tokens.bgSecondaryLight)
                .withOpacity(0.6),
          ),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? Tokens.textSecondaryDark
                      : Tokens.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingTile> items;

  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: List.generate(
          items.length,
          (index) => Column(
            children: [
              if (index != 0) const Divider(height: 1, indent: 64),
              items[index],
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.secondaryContainer.withOpacity(0.25),
        ),
        child: Icon(icon, size: 22),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
