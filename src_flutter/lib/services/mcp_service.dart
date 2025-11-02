import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/mcp.dart';
import '../utils/ids.dart';

class McpService {
  static const String _kMcpServersKey = 'mcp_servers';

  Future<List<McpServer>> getMcpServers() async {
    // TODO: Implement with Hive storage
    return [];
  }

  Future<McpServer?> getMcpServer(String id) async {
    final servers = await getMcpServers();
    try {
      return servers.firstWhere((server) => server.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<McpServer> createMcpServer(McpServer server) async {
    // TODO: Implement with Hive storage
    return server;
  }

  Future<McpServer> updateMcpServer(String id, McpServer updates) async {
    // TODO: Implement with Hive storage
    final server = await getMcpServer(id);
    if (server == null) {
      throw Exception('MCP server not found');
    }
    return server.copyWith(
      name: updates.name,
      description: updates.description,
      baseUrl: updates.baseUrl,
      type: updates.type,
      headers: updates.headers,
      timeout: updates.timeout,
      isActive: updates.isActive,
      disabledTools: updates.disabledTools,
    );
  }

  Future<void> deleteMcpServer(String id) async {
    // TODO: Implement with Hive storage
  }

  Future<List<McpTool>> getMcpTools(String serverId) async {
    final server = await getMcpServer(serverId);
    if (server == null || !server.isActive) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('${server.baseUrl}/tools'),
        headers: {
          'Content-Type': 'application/json',
          ...?server.headers,
        },
      ).timeout(Duration(seconds: server.timeout ?? 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['tools'] is List) {
          return (data['tools'] as List)
              .map((tool) => McpTool.fromJson(tool))
              .toList();
        }
      }
    } catch (e) {
      // 静默处理错误
    }

    return [];
  }

  Future<bool> testMcpServerConnection(McpServer server) async {
    try {
      final response = await http.get(
        Uri.parse('${server.baseUrl}/health'),
        headers: {
          'Content-Type': 'application/json',
          ...?server.headers,
        },
      ).timeout(Duration(seconds: server.timeout ?? 30));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  McpServerType parseServerType(String type) {
    switch (type.toLowerCase()) {
      case 'sse':
        return McpServerType.sse;
      case 'streamablehttp':
      default:
        return McpServerType.streamableHttp;
    }
  }

  String formatServerType(McpServerType type) {
    switch (type) {
      case McpServerType.sse:
        return 'sse';
      case McpServerType.streamableHttp:
        return 'streamableHttp';
    }
  }
}

final mcpServiceProvider = Provider<McpService>((ref) => McpService());