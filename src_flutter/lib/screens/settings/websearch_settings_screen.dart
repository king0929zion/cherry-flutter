import 'package:flutter/material.dart';

import '../../widgets/settings_group.dart';
import '../../theme/tokens.dart';

/// WebSearchSettingsScreen - 网页搜索设置页面
/// 像素级还原原项目UI
class WebSearchSettingsScreen extends StatefulWidget {
  const WebSearchSettingsScreen({super.key});

  @override
  State<WebSearchSettingsScreen> createState() => _WebSearchSettingsScreenState();
}

class _WebSearchSettingsScreenState extends State<WebSearchSettingsScreen> {
  String _selectedEngine = 'google';
  bool _enabled = true;

  final _engines = const [
    {'id': 'google', 'name': 'Google', 'icon': Icons.search},
    {'id': 'bing', 'name': 'Bing', 'icon': Icons.search},
    {'id': 'duckduckgo', 'name': 'DuckDuckGo', 'icon': Icons.search},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('网页搜索'), // TODO: i18n
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 启用开关
          SettingsGroup(
            children: [
              SettingsSwitchItem(
                leading: const Icon(Icons.public, size: 24),
                title: '启用网页搜索', // TODO: i18n
                subtitle: '在对话中自动搜索网络信息',
                value: _enabled,
                onChanged: (v) => setState(() => _enabled = v),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 搜索引擎选择
          const SettingsSectionTitle(title: '搜索引擎'),
          const SizedBox(height: 8),
          SettingsGroup(
            children: [
              for (var i = 0; i < _engines.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 52,
                    color: theme.dividerColor,
                  ),
                RadioListTile<String>(
                  value: _engines[i]['id'] as String,
                  groupValue: _selectedEngine,
                  onChanged: _enabled
                      ? (v) => setState(() => _selectedEngine = v!)
                      : null,
                  title: Row(
                    children: [
                      Icon(_engines[i]['icon'] as IconData, size: 20),
                      const SizedBox(width: 12),
                      Text(_engines[i]['name'] as String),
                    ],
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // 说明
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '网页搜索功能可以让 AI 助手在需要时自动搜索互联网上的信息，提供更准确和及时的回答。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
