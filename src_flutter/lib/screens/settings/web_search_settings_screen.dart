import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/web_search_settings.dart';
import '../../theme/tokens.dart';
import '../../widgets/header_bar.dart';

class WebSearchSettingsScreen extends ConsumerWidget {
  const WebSearchSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(webSearchSettingsProvider);

    String currentEngine = _inferEngine(settings.endpoint);

    return Scaffold(
      backgroundColor: isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HeaderBar(
              title: '网络搜索设置',
              leftButton: HeaderBarButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                ),
                onPress: () => context.pop(),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SettingGroup(
                    title: '搜索引擎',
                    children: [
                      _EngineTile(
                        label: 'Google',
                        selected: currentEngine == 'google',
                        onTap: () => _saveEngine(ref, 'google'),
                      ),
                      _EngineTile(
                        label: 'Bing',
                        selected: currentEngine == 'bing',
                        onTap: () => _saveEngine(ref, 'bing'),
                      ),
                      _EngineTile(
                        label: 'DuckDuckGo',
                        selected: currentEngine == 'ddg',
                        onTap: () => _saveEngine(ref, 'ddg'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SettingGroup(
                    title: '搜索选项',
                    children: const [
                      // 预留：后续接入更多选项
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

  String _inferEngine(String endpoint) {
    final e = endpoint.toLowerCase();
    if (e.contains('duckduckgo')) return 'ddg';
    if (e.contains('bing.com')) return 'bing';
    if (e.contains('googleapis.com') || e.contains('customsearch')) return 'google';
    return 'ddg';
  }

  Future<void> _saveEngine(WidgetRef ref, String engine) async {
    late final String endpoint;
    switch (engine) {
      case 'google':
        // 示例：需要配合自定义 proxy 或 API Key 使用
        endpoint = 'https://www.googleapis.com/customsearch/v1?q={q}';
        break;
      case 'bing':
        endpoint = 'https://api.bing.microsoft.com/v7.0/search?q={q}';
        break;
      case 'ddg':
      default:
        endpoint = 'https://api.duckduckgo.com/?q={q}&format=json';
    }
    await ref.read(webSearchSettingsProvider.notifier).update(
          ref.read(webSearchSettingsProvider).copyWith(endpoint: endpoint),
        );
  }
}

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
            padding: const EdgeInsets.only(left: 12, bottom: 8),
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
            borderRadius: BorderRadius.circular(12),
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

class _EngineTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _EngineTile({
    required this.label,
    required this.selected,
    required this.onTap,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.search, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check, color: isDark ? Tokens.greenDark100 : Tokens.green100),
            ],
          ),
        ),
      ),
    );
  }
}

