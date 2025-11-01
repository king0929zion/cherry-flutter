import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/assistant_service.dart';

class AssistantScreen extends ConsumerWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assistants = ref.watch(assistantsProvider);
    final svc = ref.read(assistantServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('助手')),
      body: assistants.when(
        data: (list) => ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (ctx, i) => ListTile(
            title: Text(list[i].name),
            subtitle: Text(list[i].id),
            onTap: () => context.go('/assistant/${list[i].id}'),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await svc.createAssistant();
          ref.invalidate(assistantsProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
