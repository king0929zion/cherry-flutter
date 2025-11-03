import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/message.dart';
import '../providers/provider_settings.dart';

class CancelToken {
  bool canceled = false;
  void cancel() => canceled = true;
}

class LlmService {
  const LlmService();

  Future<String> complete({required List<dynamic> context, required ProviderSettings cfg}) async {
    if (cfg.apiKey.isEmpty) {
      final prompt = context.isEmpty ? '' : _extractContent(context.last);
      return prompt.isEmpty ? '（模拟回复）' : '（模拟回复）' + prompt;
    }

    final uri = Uri.parse('${cfg.baseUrl}/chat/completions');
    final req = {
      'model': cfg.model,
      'temperature': cfg.temperature,
      'messages': context
          .map((m) => {
                'role': _extractRole(m),
                'content': _extractContent(m),
              })
          .toList(),
    };
    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${cfg.apiKey}',
      },
      body: jsonEncode(req),
    );
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw StateError('LLM 调用失败: ${resp.statusCode} ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = data['choices'] as List?;
    final content = choices != null && choices.isNotEmpty
        ? (choices.first['message']?['content'] as String? ?? '')
        : '';
    return content;
  }

  Future<void> streamComplete({
    required List<dynamic> context,
    required ProviderSettings cfg,
    required void Function(String delta) onDelta,
    CancelToken? cancelToken,
  }) async {
    if (cfg.apiKey.isEmpty) {
      final prompt = context.isEmpty ? '...' : _extractContent(context.last);
      final simulated = '（模拟回复）' + prompt;
      for (final chunk in simulated.split(RegExp(r'(?<=。|！|？|,|，|\s)'))) {
        if (cancelToken?.canceled == true) break;
        if (chunk.trim().isEmpty) continue;
        await Future.delayed(const Duration(milliseconds: 80));
        onDelta(chunk);
      }
      return;
    }

    final uri = Uri.parse('${cfg.baseUrl}/chat/completions');
    final reqBody = jsonEncode({
      'model': cfg.model,
      'temperature': cfg.temperature,
      'stream': true,
      'messages': context
          .map((m) => {
                'role': _extractRole(m),
                'content': _extractContent(m),
              })
          .toList(),
    });

    final request = http.Request('POST', uri)
      ..headers.addAll({
        'content-type': 'application/json',
        'authorization': 'Bearer ${cfg.apiKey}',
      })
      ..body = reqBody;

    final client = http.Client();
    try {
      final streamed = await client.send(request);
      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        final body = await streamed.stream.bytesToString();
        throw StateError('LLM 流式调用失败: ${streamed.statusCode} $body');
      }
      final utf8Stream = streamed.stream.transform(utf8.decoder);
      await for (final chunk in utf8Stream) {
        if (cancelToken?.canceled == true) break;
        for (final line in chunk.split('\n')) {
          final trimmed = line.trim();
          if (trimmed.isEmpty || !trimmed.startsWith('data:')) continue;
          final payload = trimmed.substring(5).trim();
          if (payload == '[DONE]') return;
          try {
            final map = jsonDecode(payload) as Map<String, dynamic>;
            final choices = map['choices'] as List?;
            if (choices != null && choices.isNotEmpty) {
              final delta = choices.first['delta'];
              final text = (delta?['content'] as String?) ?? '';
              if (text.isNotEmpty) onDelta(text);
            }
          } catch (_) {
            // ignore partial JSON chunks
          }
        }
      }
    } finally {
      client.close();
    }
  }
}

final llmServiceProvider = Provider<LlmService>((ref) => const LlmService());

String _extractContent(dynamic message) {
  if (message is MessageModel) {
    // 消息正文存储在消息块中，此处使用模型字段或空字符串作为占位
    return message.model ?? '';
  }
  if (message is Map) {
    final content = message['content'];
    if (content is String) return content;
  }
  try {
    final dynamic dynamicMessage = message;
    final value = dynamicMessage.content;
    if (value is String) return value;
  } catch (_) {
    // ignore
  }
  return '';
}

String _extractRole(dynamic message) {
  if (message is MessageModel) {
    return message.role;
  }
  if (message is Map) {
    final role = message['role'];
    if (role is String) return role;
  }
  try {
    final dynamic dynamicMessage = message;
    final role = dynamicMessage.role;
    if (role is String) return role;
  } catch (_) {
    // ignore
  }
  return 'user';
}
