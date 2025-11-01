import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/boxes.dart';
import '../../theme/tokens.dart';

class DataSourceSettingsScreen extends StatefulWidget {
  const DataSourceSettingsScreen({super.key});

  @override
  State<DataSourceSettingsScreen> createState() => _DataSourceSettingsScreenState();
}

class _DataSourceSettingsScreenState extends State<DataSourceSettingsScreen> {
  bool _isExporting = false;
  bool _isImporting = false;
  bool _isClearing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('数据管理'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _SectionHeader(
            title: '备份与迁移',
            subtitle: '将数据导出为 JSON，或导入到新的设备。',
            icon: Icons.backup_outlined,
          ),
          const SizedBox(height: 14),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '导出数据',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '将所有对话、助手、设置导出为 JSON。可粘贴到文本文件或云端备份。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _isExporting ? null : () => _exportData(context),
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.copy_outlined, size: 18),
                    label: const Text('复制 JSON 到剪贴板'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '导入数据',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '从剪贴板读取 JSON 并覆盖当前数据。请确认内容可信并符合格式。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _isImporting ? null : () => _importData(context),
                    icon: _isImporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_download_outlined, size: 18),
                    label: const Text('从剪贴板导入'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          _SectionHeader(
            title: '危险操作',
            subtitle: '慎用：此处操作会永久删除当前设备上的数据。',
            icon: Icons.warning_amber_outlined,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 14),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '清除所有数据',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '包含对话、消息、助手配置、模型设置等所有本地数据。操作不可恢复。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isClearing ? null : () => _clearAll(context),
                    icon: _isClearing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.delete_forever_outlined, size: 18),
                    label: const Text('清空全部数据'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    setState(() => _isExporting = true);
    try {
      final dump = {
        'topics': Boxes.topics.toMap(),
        'messages': Boxes.messages.toMap(),
        'blocks': Boxes.blocks.toMap(),
        'prefs': Boxes.prefs.toMap(),
      };
      await Clipboard.setData(ClipboardData(text: jsonEncode(dump)));
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('数据已复制到剪贴板')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('导出失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _importData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认导入数据'),
        content: const Text('导入将覆盖当前所有数据，且无法撤销。是否继续？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('继续导入')),
        ],
      ),
    );

    if (confirm != true || mounted == false) return;
    setState(() => _isImporting = true);

    try {
      final data = await Clipboard.getData('text/plain');
      if (data?.text == null || data!.text!.trim().isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('剪贴板为空，无法导入')));
        return;
      }

      final map = jsonDecode(data.text!) as Map<String, dynamic>;
      await Boxes.topics.clear();
      await Boxes.messages.clear();
      await Boxes.blocks.clear();
      await Boxes.prefs.clear();

      if (map['topics'] is Map) {
        final topics = Map<String, dynamic>.from(map['topics'] as Map);
        for (final entry in topics.entries) {
          await Boxes.topics.put(entry.key, Map<String, dynamic>.from(entry.value as Map));
        }
      }
      if (map['messages'] is Map) {
        final messages = Map<String, dynamic>.from(map['messages'] as Map);
        for (final entry in messages.entries) {
          await Boxes.messages.put(entry.key, Map<String, dynamic>.from(entry.value as Map));
        }
      }
      if (map['blocks'] is Map) {
        final blocks = Map<String, dynamic>.from(map['blocks'] as Map);
        for (final entry in blocks.entries) {
          await Boxes.blocks.put(entry.key, Map<String, dynamic>.from(entry.value as Map));
        }
      }
      if (map['prefs'] is Map) {
        final prefs = Map<String, dynamic>.from(map['prefs'] as Map);
        for (final entry in prefs.entries) {
          await Boxes.prefs.put(entry.key, entry.value);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('导入成功，请重启应用')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('导入失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<void> _clearAll(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('危险操作提示'),
        content: const Text('这将删除所有对话、助手及设置数据，操作不可恢复。是否继续？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确定删除'),
          ),
        ],
      ),
    );

    if (confirm != true || mounted == false) return;
    setState(() => _isClearing = true);

    try {
      await Boxes.topics.clear();
      await Boxes.messages.clear();
      await Boxes.blocks.clear();
      await Boxes.prefs.clear();

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('所有数据已清除')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('清除失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _isClearing = false);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? color;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tint = color ?? theme.colorScheme.primary;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: tint.withOpacity(isDark ? 0.18 : 0.12),
          ),
          child: Icon(icon, color: tint),
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
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? Tokens.textSecondaryDark
                      : Tokens.textSecondaryLight,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
