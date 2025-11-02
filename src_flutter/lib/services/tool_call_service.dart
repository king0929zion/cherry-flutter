import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/tool_call.dart';
import '../utils/ids.dart';

class ToolCallService {
  static const String _kToolCallsKey = 'tool_calls';
  final String _uuid = const Uuid().v4();

  Future<List<ToolCallBlock>> getToolCallsByMessage(String messageId) async {
    // TODO: Implement with Hive storage
    return [];
  }

  Future<ToolCallBlock> createToolCall({
    required String messageId,
    required String name,
    required Map<String, dynamic> arguments,
    Map<String, dynamic>? metadata,
  }) async {
    final toolCall = ToolCall(
      id: newId(),
      name: name,
      arguments: arguments,
      status: ToolCallStatus.pending,
      createdAt: DateTime.now(),
    );

    final block = ToolCallBlock(
      id: newId(),
      messageId: messageId,
      toolCall: toolCall,
      metadata: metadata,
    );

    // TODO: Save to Hive storage
    return block;
  }

  Future<void> updateToolCallStatus(
    String toolCallId,
    ToolCallStatus status, {
    dynamic response,
    String? error,
  }) async {
    // TODO: Implement with Hive storage
  }

  Future<void> deleteToolCall(String toolCallId) async {
    // TODO: Implement with Hive storage
  }

  Future<void> deleteToolCallsByMessage(String messageId) async {
    // TODO: Implement with Hive storage
  }

  String _getToolDisplayName(String name) {
    if (name.startsWith('builtin_')) {
      return name.replaceFirst('builtin_', '');
    }
    return name;
  }

  bool _isBuiltinTool(String name) {
    return name.startsWith('builtin_');
  }
}

final toolCallServiceProvider = Provider<ToolCallService>((ref) => ToolCallService());