import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Cherry Menu')),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Home / Chat'),
              onTap: () => context.go('/home/chat/default'),
            ),
            ListTile(
              leading: const Icon(Icons.topic),
              title: const Text('Topic'),
              onTap: () => context.go('/home/topic'),
            ),
            ListTile(
              leading: const Icon(Icons.assistant),
              title: const Text('Assistant'),
              onTap: () => context.go('/assistant'),
            ),
            ListTile(
              leading: const Icon(Icons.extension),
              title: const Text('MCP'),
              onTap: () => context.go('/mcp'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => context.go('/settings'),
            ),
          ],
        ),
      ),
    );
  }
}
