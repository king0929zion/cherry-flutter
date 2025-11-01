import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/boxes.dart';
import '../../providers/theme.dart';

class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('通用设置')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('深色模式'),
            value: theme == ThemeMode.dark,
            onChanged: (v) => ref.read(themeModeProvider.notifier).set(v ? ThemeMode.dark : ThemeMode.light),
          ),
          const Divider(),
          ListTile(
            title: const Text('导出数据到剪贴板'),
            onTap: () async {
              final dump = {
                'topics': Boxes.topics.toMap(),
                'messages': Boxes.messages.toMap(),
                'blocks': Boxes.blocks.toMap(),
                'prefs': Boxes.prefs.toMap(),
              };
              await Clipboard.setData(ClipboardData(text: jsonEncode(dump)));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
              }
            },
          ),
          ListTile(
            title: const Text('从剪贴板导入数据 (覆盖)'),
            onTap: () async {
              final data = await Clipboard.getData('text/plain');
              if (data?.text == null) return;
              try {
                final map = jsonDecode(data!.text!) as Map<String, dynamic>;
                await Boxes.topics.clear();
                await Boxes.messages.clear();
                await Boxes.blocks.clear();
                await Boxes.prefs.clear();
                final topics = Map<String, dynamic>.from(map['topics'] as Map);
                final messages = Map<String, dynamic>.from(map['messages'] as Map);
                final blocks = Map<String, dynamic>.from(map['blocks'] as Map);
                final prefs = Map<String, dynamic>.from(map['prefs'] as Map);
                for (final e in topics.entries) {
                  await Boxes.topics.put(e.key, Map<String, dynamic>.from(e.value as Map));
                }
                for (final e in messages.entries) {
                  await Boxes.messages.put(e.key, Map<String, dynamic>.from(e.value as Map));
                }
                for (final e in blocks.entries) {
                  await Boxes.blocks.put(e.key, Map<String, dynamic>.from(e.value as Map));
                }
                for (final e in prefs.entries) {
                  await Boxes.prefs.put(e.key, e.value);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('导入完成')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('导入失败: $e')));
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

Map _parseMap(String s) {
  // 非严格解析，仅为 demo；建议生产中使用 JSON.
  // 尝试用 Dart 的 Map 字面量格式由用户粘贴生成。
  // 这里直接借助 Dart 的解析会很复杂，故仅支持我们导出的格式。
  // 为降低复杂度，这里抛出异常提示用户使用相同版本导出的内容。
  throw '请先使用本应用的“导出数据到剪贴板”再导入（当前实现仅支持同格式的回导）';
}
