import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/boxes.dart';
import '../../providers/locale.dart';
import '../../providers/theme.dart';
import '../../theme/tokens.dart';

class GeneralSettingsScreen extends ConsumerStatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  ConsumerState<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends ConsumerState<GeneralSettingsScreen> {
  ThemeMode? _pendingTheme;
  Locale? _pendingLocale;
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('通用设置'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _SectionTitle(
            icon: Icons.palette_outlined,
            title: '外观与语言',
            description: '控制主题、语言等外观相关选项。',
          ),
          const SizedBox(height: 14),
          _SettingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(
                  icon: Icons.dark_mode_outlined,
                  title: '主题模式',
                  subtitle: '选择符合当前环境的明暗模式。',
                ),
                const SizedBox(height: 12),
                ToggleButtons(
                  borderRadius: BorderRadius.circular(12),
                  constraints: const BoxConstraints(minHeight: 42, minWidth: 90),
                  isSelected: ThemeMode.values.map((mode) {
                    final current = _pendingTheme ?? themeMode;
                    return mode == current;
                  }).toList(),
                  onPressed: (index) {
                    setState(() => _pendingTheme = ThemeMode.values[index]);
                    ref.read(themeModeProvider.notifier).set(ThemeMode.values[index]);
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('跟随系统'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('浅色'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('深色'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _CardHeader(
                  icon: Icons.language_outlined,
                  title: '应用语言',
                  subtitle: '立即切换界面所使用的语言。',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  children: [
                    ChoiceChip(
                      label: const Text('🇨🇳 中文'),
                      selected: (_pendingLocale ?? locale)?.languageCode == 'zh',
                      onSelected: (_) {
                        setState(() => _pendingLocale = const Locale('zh'));
                        ref.read(localeProvider.notifier).set(const Locale('zh'));
                      },
                    ),
                    ChoiceChip(
                      label: const Text('🇺🇸 English'),
                      selected: (_pendingLocale ?? locale)?.languageCode == 'en',
                      onSelected: (_) {
                        setState(() => _pendingLocale = const Locale('en'));
                        ref.read(localeProvider.notifier).set(const Locale('en'));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _SectionTitle(
            icon: Icons.storage_outlined,
            title: '数据与备份',
            description: '导出或导入你的对话、助手与设置数据。',
          ),
          const SizedBox(height: 14),
          _SettingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(
                  icon: Icons.cloud_upload_outlined,
                  title: '导出数据',
                  subtitle: '将所有数据复制到剪贴板，可用于备份或迁移。',
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _isExporting ? null : () => _exportData(context),
                  icon: _isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.copy_outlined, size: 18),
                  label: const Text('复制 JSON 数据'),
                ),
                const SizedBox(height: 20),
                _CardHeader(
                  icon: Icons.cloud_download_outlined,
                  title: '导入数据',
                  subtitle: '从剪贴板读取 JSON 并覆盖当前所有数据。',
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isImporting ? null : () => _importData(context),
                  icon: _isImporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.insert_drive_file_outlined, size: 18),
                  label: const Text('从剪贴板导入'),
                ),
                const SizedBox(height: 14),
                Text(
                  '导入数据将覆盖当前的对话、助手与设置。建议在操作前做好备份。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? Tokens.textSecondaryDark
                            : Tokens.textSecondaryLight,
                        height: 1.45,
                      ),
                ),
              ],
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
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('数据已复制到剪贴板')));
      }
    } catch (e) {
      if (context.mounted) {
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
        content: const Text(
          '导入操作会覆盖当前所有对话、助手与设置，且无法撤销。确定要继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('继续导入'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    setState(() => _isImporting = true);

    try {
      final data = await Clipboard.getData('text/plain');
      if (data?.text == null || data!.text!.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('剪贴板为空，请先复制备份数据')),
          );
        }
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('导入成功，请重启应用以生效')),
        );
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
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.description,
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
            color: isDark ? Tokens.cardDark : Tokens.cardLight,
            border: Border.all(
              color: (isDark ? Tokens.borderDark : Tokens.borderLight).withOpacity(0.6),
            ),
          ),
          child: Icon(icon, size: 22),
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
                description,
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

class _SettingCard extends StatelessWidget {
  final Widget child;

  const _SettingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CardHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: (isDark ? Tokens.bgSecondaryDark : Tokens.bgSecondaryLight)
                .withOpacity(0.7),
          ),
          child: Icon(icon, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? Tokens.textSecondaryDark
                      : Tokens.textSecondaryLight,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
