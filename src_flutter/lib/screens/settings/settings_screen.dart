import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(title: const Text('通用设置'), onTap: () => context.go('/settings/general')),
          ListTile(title: const Text('助手设置'), onTap: () => context.go('/settings/assistant')),
          ListTile(title: const Text('供应商设置'), onTap: () => context.go('/settings/providers')),
          ListTile(title: const Text('数据源设置'), onTap: () => context.go('/settings/data-sources')),
          ListTile(title: const Text('网页搜索设置'), onTap: () => context.go('/settings/web-search')),
          ListTile(title: const Text('关于'), onTap: () => context.go('/settings/about')),
        ],
      ),
    );
  }
}
