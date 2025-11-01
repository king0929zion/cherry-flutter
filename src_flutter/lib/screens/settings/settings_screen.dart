import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/tokens.dart';
import '../../widgets/settings_group.dart';

/// SettingsScreen - 设置主页面
/// 完全复刻原项目的布局和样式
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'), // TODO: i18n
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 个人信息组
          SettingsGroup(
            children: [
              SettingsItem(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Tokens.brand,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: 'Cherry Studio', // TODO: 从设置读取用户名
                onTap: () => context.go('/settings/about/personal'),
              ),
            ],
          ),
          
          const SizedBox(height: 24), // gap-6
          
          // 模型与服务
          const SettingsSectionTitle(title: '模型与服务'), // TODO: i18n
          const SizedBox(height: 8),
          SettingsGroup(
            children: [
              SettingsItem(
                leading: const Icon(Icons.cloud_outlined, size: 24),
                title: '供应商设置', // TODO: i18n
                subtitle: '配置 API 端点和密钥',
                onTap: () => context.go('/settings/providers'),
              ),
              _buildDivider(theme),
              SettingsItem(
                leading: const Icon(Icons.smart_toy_outlined, size: 24),
                title: '助手设置', // TODO: i18n
                subtitle: '管理助手配置',
                onTap: () => context.go('/settings/assistant'),
              ),
              _buildDivider(theme),
              SettingsItem(
                leading: const Icon(Icons.public, size: 24),
                title: '网页搜索', // TODO: i18n
                subtitle: '配置搜索引擎',
                onTap: () => context.go('/settings/web-search'),
              ),
            ],
          ),
          
          const SizedBox(height: 24), // gap-6
          
          // 通用设置
          const SettingsSectionTitle(title: '通用'), // TODO: i18n
          const SizedBox(height: 8),
          SettingsGroup(
            children: [
              SettingsItem(
                leading: const Icon(Icons.settings_outlined, size: 24),
                title: '通用设置', // TODO: i18n
                subtitle: '主题、语言等',
                onTap: () => context.go('/settings/general'),
              ),
              _buildDivider(theme),
              SettingsItem(
                leading: const Icon(Icons.storage_outlined, size: 24),
                title: '数据管理', // TODO: i18n
                subtitle: '备份与导入',
                onTap: () => context.go('/settings/data-sources'),
              ),
            ],
          ),
          
          const SizedBox(height: 24), // gap-6
          
          // 关于
          const SettingsSectionTitle(title: '信息'), // TODO: i18n
          const SizedBox(height: 8),
          SettingsGroup(
            children: [
              SettingsItem(
                leading: const Icon(Icons.info_outline, size: 24),
                title: '关于', // TODO: i18n
                subtitle: '版本信息',
                onTap: () => context.go('/settings/about'),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 52, // 图标宽度 24 + 左边距 16 + 间距 12
      color: theme.dividerColor,
    );
  }
}
