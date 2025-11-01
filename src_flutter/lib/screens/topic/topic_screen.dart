import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/topic_service.dart';

class TopicScreen extends ConsumerWidget {
  const TopicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider);
    final svc = ref.read(topicServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('主题')),
      body: topicsAsync.when(
        data: (list) => ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final t = list[i];
            return ListTile(
              title: Text(t.name),
              subtitle: Text(t.id),
              onTap: () async {
                await svc.setCurrentTopic(t.id);
                if (context.mounted) context.go('/home/chat/${t.id}');
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await svc.deleteTopic(t.id);
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final t = await svc.createTopic();
          if (context.mounted) context.go('/home/chat/${t.id}');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
