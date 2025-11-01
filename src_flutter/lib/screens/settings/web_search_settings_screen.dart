import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/web_search_settings.dart';

class WebSearchSettingsScreen extends ConsumerWidget {
  const WebSearchSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(webSearchSettingsProvider);
    final notifier = ref.read(webSearchSettingsProvider.notifier);
    final endpointCtrl = TextEditingController(text: s.endpoint);
    return Scaffold(
      appBar: AppBar(title: const Text('网页搜索设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Endpoint 模板 (使用 {q} 作为查询占位)'),
            controller: endpointCtrl,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              await notifier.update(s.copyWith(endpoint: endpointCtrl.text.trim()));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存')));
              }
            },
            child: const Text('保存'),
          )
        ],
      ),
    );
  }
}
