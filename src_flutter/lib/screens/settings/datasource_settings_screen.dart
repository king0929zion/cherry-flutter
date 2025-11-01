import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '../../data/boxes.dart';
import '../../widgets/settings_group.dart';
import '../../theme/tokens.dart';

/// DataSourceSettingsScreen - 数据源设置页面
/// 数据备份和恢复
class DataSourceSettingsScreen extends StatelessWidget {
  const DataSourceSettingsScreen({super.key});

  Future<void> _exportData(BuildContext context) async {
    try {
      final dump = {
        'topics': Boxes.topics.toMap(),
        'messages': Boxes.messages.toMap(),
        'blocks': Boxes.blocks.toMap(),
        'prefs': Boxes.prefs.toMap(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await Clipboard.setData(ClipboardData(text: jsonEncode(dump)));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('数据已导出到剪贴板'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    // 确认对话框
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认导入'),
        content: const Text(
          '导入数据将完全覆盖当前所有数据，包括：\n'
          '• 所有对话主题\n'
          '• 所有消息记录\n'
          '• 所有设置项\n\n'
          '此操作不可撤销，确定要继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('确定导入'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      final data = await Clipboard.getData('text/plain');
      if (data?.text == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('剪贴板为空，请先导出数据')),
          );
        }
        return;
      }

      final map = jsonDecode(data!.text!) as Map<String, dynamic>;
      
      // 清空现有数据
      await Boxes.topics.clear();
      await Boxes.messages.clear();
      await Boxes.blocks.clear();
      await Boxes.prefs.clear();
      
      // 导入新数据
      if (map['topics'] != null) {
        final topics = Map<String, dynamic>.from(map['topics'] as Map);
        for (final e in topics.entries) {
          await Boxes.topics.put(e.key, Map<String, dynamic>.from(e.value as Map));
        }
      }
      
      if (map['messages'] != null) {
        final messages = Map<String, dynamic>.from(map['messages'] as Map);
        for (final e in messages.entries) {
          await Boxes.messages.put(e.key, Map<String, dynamic>.from(e.value as Map));
        }
      }
      
      if (map['blocks'] != null) {
        final blocks = Map<String, dynamic>.from(map['blocks'] as Map);
        for (final e in blocks.entries) {
          await Boxes.blocks.put(e.key, Map<String, dynamic>.from(e.value as Map));
        }
      }
      
      if (map['prefs'] != null) {
        final prefs = Map<String, dynamic>.from(map['prefs'] as Map);
        for (final e in prefs.entries) {
          await Boxes.prefs.put(e.key, e.value);
        }
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('导入成功！请重启应用以查看更新'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ 危险操作'),
        content: const Text(
          '即将删除所有数据，包括：\n'
          '• 所有对话主题和消息\n'
          '• 所有助手配置\n'
          '• 所有设置项\n\n'
          '此操作不可撤销！确定要继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('确定删除'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      await Boxes.topics.clear();
      await Boxes.messages.clear();
      await Boxes.blocks.clear();
      await Boxes.prefs.clear();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('所有数据已清除')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清除失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('数据管理'), // TODO: i18n
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 数据备份
          const SettingsSectionTitle(title: '数据备份'),
          const SizedBox(height: 8),
          SettingsGroup(
            children: [
              SettingsItem(
                leading: const Icon(Icons.cloud_upload_outlined, size: 24),
                title: '导出数据',
                subtitle: '导出所有数据到剪贴板',
                onTap: () => _exportData(context),
              ),
              Divider(
                height: 1,
                thickness: 1,
                indent: 52,
                color: theme.dividerColor,
              ),
              SettingsItem(
                leading: const Icon(Icons.cloud_download_outlined, size: 24),
                title: '导入数据',
                subtitle: '从剪贴板导入数据（覆盖）',
                onTap: () => _importData(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 危险操作
          const SettingsSectionTitle(title: '危险操作'),
          const SizedBox(height: 8),
          SettingsGroup(
            children: [
              SettingsItem(
                leading: const Icon(Icons.delete_forever, size: 24, color: Colors.red),
                title: '清除所有数据',
                subtitle: '删除所有对话、消息和设置',
                onTap: () => _clearAllData(context),
                trailing: const Icon(Icons.warning, color: Colors.red, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 说明
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '提示：\n'
              '• 导出的数据包含所有对话、消息和设置\n'
              '• 可以在不同设备间迁移数据\n'
              '• 建议定期备份重要数据\n'
              '• 导入操作会覆盖当前所有数据',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
