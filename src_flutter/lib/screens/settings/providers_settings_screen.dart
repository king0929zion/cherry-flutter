import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/provider_settings.dart';

class ProvidersSettingsScreen extends ConsumerWidget {
  const ProvidersSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(providerSettingsProvider);
    final notifier = ref.read(providerSettingsProvider.notifier);

    final providerCtrl = TextEditingController(text: settings.providerId);
    final baseUrlCtrl = TextEditingController(text: settings.baseUrl);
    final modelCtrl = TextEditingController(text: settings.model);
    final apiKeyCtrl = TextEditingController(text: settings.apiKey);
    final tempCtrl = TextEditingController(text: settings.temperature.toString());

    return Scaffold(
      appBar: AppBar(title: const Text('LLM 提供商设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(decoration: const InputDecoration(labelText: 'Provider ID'), controller: providerCtrl),
          const SizedBox(height: 12),
          TextField(decoration: const InputDecoration(labelText: 'Base URL'), controller: baseUrlCtrl),
          const SizedBox(height: 12),
          TextField(decoration: const InputDecoration(labelText: 'Model'), controller: modelCtrl),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(labelText: 'API Key'),
            controller: apiKeyCtrl,
            obscureText: true,
          ),
          const SizedBox(height: 12),
          TextField(decoration: const InputDecoration(labelText: 'Temperature'), controller: tempCtrl),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              final t = double.tryParse(tempCtrl.text.trim());
              await notifier.update(settings.copyWith(
                providerId: providerCtrl.text.trim(),
                baseUrl: baseUrlCtrl.text.trim(),
                model: modelCtrl.text.trim(),
                apiKey: apiKeyCtrl.text.trim(),
                temperature: t ?? settings.temperature,
              ));
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
