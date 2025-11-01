import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/mcp_settings.dart';
import '../../utils/ids.dart';

class McpScreen extends ConsumerWidget {
  const McpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(mcpSettingsProvider);
    final notifier = ref.read(mcpSettingsProvider.notifier);
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('MCP 服务器')),
      body: ListView.separated(
        itemCount: servers.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final s = servers[i];
          return ListTile(
            title: Text(s.name),
            subtitle: Text(s.endpoint),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => notifier.remove(s.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('添加服务器'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(decoration: const InputDecoration(labelText: '名称'), controller: nameCtrl),
                  TextField(decoration: const InputDecoration(labelText: 'Endpoint'), controller: urlCtrl),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
                FilledButton(
                  onPressed: () async {
                    await notifier.add(McpServer(id: newId(), name: nameCtrl.text.trim(), endpoint: urlCtrl.text.trim()));
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('添加'),
                )
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
