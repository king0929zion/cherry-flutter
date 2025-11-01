import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/boxes.dart';
import '../../providers/theme.dart';
import '../../providers/locale.dart';
import '../../widgets/settings_group.dart';

/// GeneralSettingsScreen - 通用设置页面
/// 严格对齐原项目UI和布局
class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '跟随系统'; // TODO: i18n
      case ThemeMode.light:
        return '浅色';
      case ThemeMode.dark:
        return '深色';
    }
  }

  String _getLanguageLabel(Locale? locale) {
    if (locale == null) return '🇨🇳 中文';
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸 English';
      case 'zh':
        return '🇨🇳 中文';
      default:
        return '🇨🇳 中文';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeModeProvider);
    final loc = ref.watch(localeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('通用设置'), // TODO: i18n
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 显示设置
          const SettingsSectionTitle(title: '显示'), // TODO: i18n
          const SizedBox(height: 8),
          SettingsGroup(
            children: [
              SettingsItem(
                leading: const Icon(Icons.palette_outlined, size: 24),
                title: '主题', // TODO: i18n
                subtitle: _getThemeLabel(theme),
                onTap: () => _showThemeDialog(context, ref, theme),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 通用设置
          const SettingsSectionTitle(title: '通用'), // TODO: i18n
          const SizedBox(height: 8),
          SettingsGroup(
            children: [
              SettingsItem(
                leading: const Icon(Icons.language, size: 24),
                title: '语言', // TODO: i18n
                subtitle: _getLanguageLabel(loc),
                onTap: () => _showLanguageDialog(context, ref, loc),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 数据管理
          const SettingsSectionTitle(title: '数据管理'), // TODO: i18n
          const SizedBox(height: 8),
          SettingsGroup(
            children: [
              SettingsItem(
                leading: const Icon(Icons.cloud_upload_outlined, size: 24),
                title: '导出数据', // TODO: i18n
                subtitle: '复制到剪贴板',
                onTap: () => _exportData(context),
              ),
              Divider(
                height: 1,
                thickness: 1,
                indent: 52,
                color: Theme.of(context).dividerColor,
              ),
              SettingsItem(
                leading: const Icon(Icons.cloud_download_outlined, size: 24),
                title: '导入数据', // TODO: i18n
                subtitle: '从剪贴板导入',
                onTap: () => _importData(context)
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeMode current) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('跟随系统'),
              value: ThemeMode.system,
              groupValue: current,
              onChanged: (v) {
                if (v != null) ref.read(themeModeProvider.notifier).set(v);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('浅色'),
              value: ThemeMode.light,
              groupValue: current,
              onChanged: (v) {
                if (v != null) ref.read(themeModeProvider.notifier).set(v);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('深色'),
              value: ThemeMode.dark,
              groupValue: current,
              onChanged: (v) {
                if (v != null) ref.read(themeModeProvider.notifier).set(v);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, Locale? current) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('🇨🇳 中文'),
              value: 'zh',
              groupValue: current?.languageCode ?? 'zh',
              onChanged: (v) {
                ref.read(localeProvider.notifier).set(const Locale('zh'));
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('🇺🇸 English'),
              value: 'en',
              groupValue: current?.languageCode ?? 'zh',
              onChanged: (v) {
                ref.read(localeProvider.notifier).set(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final dump = {
        'topics': Boxes.topics.toMap(),
        'messages': Boxes.messages.toMap(),
        'blocks': Boxes.blocks.toMap(),
        'prefs': Boxes.prefs.toMap(),
      };
      await Clipboard.setData(ClipboardData(text: jsonEncode(dump)));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据已复制到剪贴板')),
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认导入'),
        content: const Text('导入数据将覆盖当前所有数据，确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确定'),
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
            const SnackBar(content: Text('剪贴板为空')),
          );
        }
        return;
      }

      final map = jsonDecode(data!.text!) as Map<String, dynamic>;
      await Boxes.topics.clear();
      await Boxes.messages.clear();
      await Boxes.blocks.clear();
      await Boxes.prefs.clear();
      
      final topics = Map<String, dynamic>.from(map['topics'] as Map);
      final messages = Map<String, dynamic>.from(map['messages'] as Map);
      final blocks = Map<String, dynamic>.from(map['blocks'] as Map);
      final prefs = Map<String, dynamic>.from(map['prefs'] as Map);
      
      for (final e in topics.entries) {
        await Boxes.topics.put(e.key, Map<String, dynamic>.from(e.value as Map));
      }
      for (final e in messages.entries) {
        await Boxes.messages.put(e.key, Map<String, dynamic>.from(e.value as Map));
      }
      for (final e in blocks.entries) {
        await Boxes.blocks.put(e.key, Map<String, dynamic>.from(e.value as Map));
      }
      for (final e in prefs.entries) {
        await Boxes.prefs.put(e.key, e.value);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('导入完成，请重启应用')),
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
}
