import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/message.dart';
import '../providers/provider_settings.dart';

class LlmService {
  final ProviderRef ref;
  LlmService(this.ref);

  Future<String> complete({required List<ChatMessage> context}) async {
    final cfg = ref.read(providerSettingsProvider);
    if (cfg.apiKey.isEmpty) {
      throw StateError('请先在设置中配置 OpenAI API Key');
    }

    final uri = Uri.parse('${cfg.baseUrl}/chat/completions');
    final req = {
      'model': cfg.model,
      'temperature': cfg.temperature,
      'messages': context.map((m) => {'role': m.role, 'content': m.content}).toList(),
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
}

final llmServiceProvider = Provider<LlmService>((ref) => LlmService(ref));
