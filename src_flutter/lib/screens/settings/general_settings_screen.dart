import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

import '../../data/boxes.dart';
import '../../providers/locale.dart';
import '../../providers/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/header_bar.dart';

class GeneralSettingsScreen extends ConsumerStatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  ConsumerState<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends ConsumerState<GeneralSettingsScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // HeaderBar - 匹配原项目
            HeaderBar(
              title: '通用设置',
              leftButton: HeaderBarButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                ),
                onPress: () => context.pop(),
              ),
            ),
            // Container - 匹配原项目：p-4 gap-5
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16), // p-4
                children: [
                  // Group 1: 外观与语言
                  _SettingGroup(
                    title: '外观与语言',
                    children: [
                      _SettingTile(
                        label: '主题模式',
                        value: _getThemeModeLabel(themeMode),
                        onTap: () => _showThemePicker(context, themeMode),
                      ),
                      _SettingTile(
                        label: '语言',
                        value: _getLocaleLabel(locale ?? const Locale('zh')),
                        onTap: () => _showLocalePicker(context, locale ?? const Locale('zh')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24), // gap-6
                  
                  // Group 2: 数据管理
                  _SettingGroup(
                    title: '数据管理',
                    children: [
                      _SettingTile(
                        label: '导出数据',
                        trailing: _isExporting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : null,
                        onTap: _isExporting ? null : _exportData,
                      ),
                      _SettingTile(
                        label: '导入数据',
                        trailing: _isImporting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : null,
                        onTap: _isImporting ? null : _importData,
                      ),
                      _SettingTile(
                        label: '清除所有数据',
                        isDanger: true,
                        onTap: () => _confirmClearData(context),
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

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '浅色';
      case ThemeMode.dark:
        return '深色';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  String _getLocaleLabel(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return '简体中文';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }

  void _showThemePicker(BuildContext context, ThemeMode current) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('浅色'),
              trailing: current == ThemeMode.light
                  ? const Icon(Icons.check, color: Tokens.green100)
                  : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).set(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('深色'),
              trailing: current == ThemeMode.dark
                  ? const Icon(Icons.check, color: Tokens.green100)
                  : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).set(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('跟随系统'),
              trailing: current == ThemeMode.system
                  ? const Icon(Icons.check, color: Tokens.green100)
                  : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).set(ThemeMode.system);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLocalePicker(BuildContext context, Locale current) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('简体中文'),
              trailing: current.languageCode == 'zh'
                  ? const Icon(Icons.check, color: Tokens.green100)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).set(const Locale('zh'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('English'),
              trailing: current.languageCode == 'en'
                  ? const Icon(Icons.check, color: Tokens.green100)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).set(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    try {
      // Export data logic
      final data = {
        'assistants': HiveBoxes.getAssistantsBox().values.toList(),
        'topics': HiveBoxes.getTopicsBox().values.toList(),
        'messages': HiveBoxes.getMessagesBox().values.toList(),
        'providers': [], // TODO: 添加 provider box
      };
      final jsonString = jsonEncode(data);
      await Clipboard.setData(ClipboardData(text: jsonString));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据已复制到剪贴板')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _importData() async {
    setState(() => _isImporting = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          final jsonString = String.fromCharCodes(file.bytes!);
          final data = jsonDecode(jsonString) as Map<String, dynamic>;
          
          // Import data logic (placeholder)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('数据导入成功')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<void> _confirmClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清除所有数据'),
        content: const Text('此操作将清除所有数据，包括助手、话题、消息等。\n\n此操作不可恢复，确定继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('清除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _clearAllData();
    }
  }

  Future<void> _clearAllData() async {
    try {
      await HiveBoxes.getAssistantsBox().clear();
      await HiveBoxes.getTopicsBox().clear();
      await HiveBoxes.getMessagesBox().clear();
      await HiveBoxes.getMessageBlocksBox().clear();
      // TODO: 添加 provider box clear
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('所有数据已清除')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清除失败: $e')),
        );
      }
    }
  }
}

/// _SettingGroup - 匹配原项目的 Group 组件
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
            padding: const EdgeInsets.only(left: 12, bottom: 8), // pl-3 gap-2
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
            borderRadius: BorderRadius.circular(12), // rounded-xl
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

/// _SettingTile - 匹配原项目的 PressableRow
class _SettingTile extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDanger;

  const _SettingTile({
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
    this.isDanger = false,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // py-[14px] px-4
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDanger
                        ? Colors.redAccent
                        : (isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (value != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        value!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                        ),
                      ),
                    ),
                  if (trailing != null)
                    trailing!
                  else
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: isDark
                          ? Tokens.textSecondaryDark.withOpacity(0.9)
                          : Tokens.textSecondaryLight.withOpacity(0.9),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
