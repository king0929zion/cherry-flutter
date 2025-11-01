import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import '../services/prefs_service.dart';

class McpServer {
  final String id;
  final String name;
  final String endpoint;
  const McpServer({required this.id, required this.name, required this.endpoint});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'endpoint': endpoint};
  static McpServer fromJson(Map m) => McpServer(
        id: m['id'] as String,
        name: m['name'] as String,
        endpoint: m['endpoint'] as String,
      );
}

class McpSettingsNotifier extends StateNotifier<List<McpServer>> {
  McpSettingsNotifier() : super(const []) {
    load();
  }

  static const _kKey = 'mcp.servers';

  Future<void> load() async {
    final list = (prefsService.getString(_kKey) ?? '[]');
    try {
      final data = (list.isEmpty ? [] : (jsonDecode(list) as List)).cast<dynamic>();
      state = data.map((e) => McpServer.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      state = const [];
    }
  }

  Future<void> save() async {
    final json = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefsService.setString(_kKey, json);
  }

  Future<void> add(McpServer s) async {
    state = [...state, s];
    await save();
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await save();
  }
}

final mcpSettingsProvider = StateNotifierProvider<McpSettingsNotifier, List<McpServer>>((ref) {
  return McpSettingsNotifier();
});
