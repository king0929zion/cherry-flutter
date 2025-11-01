import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/assistant_service.dart';

class AssistantDetailScreen extends ConsumerWidget {
  final String assistantId;
  const AssistantDetailScreen({super.key, required this.assistantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(assistantServiceProvider).getAssistant(assistantId),
      builder: (ctx, snap) {
        if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final a = snap.data as Assistant?;
        if (a == null) return const Scaffold(body: Center(child: Text('未找到助手')));
        final nameCtrl = TextEditingController(text: a.name);
        final promptCtrl = TextEditingController(text: a.prompt ?? '');
        return Scaffold(
          appBar: AppBar(title: const Text('助手详情')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(decoration: const InputDecoration(labelText: '名称'), controller: nameCtrl),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: '系统提示词'),
                controller: promptCtrl,
                minLines: 4,
                maxLines: 12,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  final list = await ref.read(assistantServiceProvider).getAssistants();
                  final idx = list.indexWhere((e) => e.id == a.id);
                  if (idx >= 0) {
                    list[idx] = a.copyWith(name: nameCtrl.text.trim(), prompt: promptCtrl.text);
                    await ref.read(assistantServiceProvider).saveAssistants(list);
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
                child: const Text('保存'),
              )
            ],
          ),
        );
      },
    );
  }
}
