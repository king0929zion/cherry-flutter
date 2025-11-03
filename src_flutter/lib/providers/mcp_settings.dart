import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import '../services/prefs_service.dart';

class McpServer {
  final String id;
  final String name;
  final String? description;
  final String endpoint;
  final String? type;
  final bool isActive;
  const McpServer({
    required this.id, 
    required this.name, 
    this.description,
    required this.endpoint,
    this.type,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 
    'name': name, 
    'description': description,
    'endpoint': endpoint,
    'type': type,
    'isActive': isActive,
  };
  static McpServer fromJson(Map m) => McpServer(
        id: m['id'] as String,
        name: m['name'] as String,
        description: m['description'] as String?,
        endpoint: m['endpoint'] as String,
        type: m['type'] as String?,
        isActive: m['isActive'] as bool? ?? true,
      );
  
  McpServer copyWith({
    String? id,
    String? name,
    String? description,
    String? endpoint,
    String? type,
    bool? isActive,
  }) {
    return McpServer(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      endpoint: endpoint ?? this.endpoint,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
    );
  }
}

class McpSettingsNotifier extends Notifier<List<McpServer>> {
  @override
  List<McpServer> build() {
    _load();
    return const [];
  }

  static const _kKey = 'mcp.servers';

  Future<void> _load() async {
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

  Future<void> toggleActive(String id) async {
    state = state.map((e) {
      if (e.id == id) {
        return e.copyWith(isActive: !e.isActive);
      }
      return e;
    }).toList();
    await save();
  }

  Future<void> updateServer(McpServer server) async {
    state = state.map((e) => e.id == server.id ? server : e).toList();
    await save();
  }
}

final mcpSettingsProvider = NotifierProvider<McpSettingsNotifier, List<McpServer>>(McpSettingsNotifier.new);
