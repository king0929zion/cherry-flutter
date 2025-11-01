import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../providers/web_search_settings.dart';

class WebSearchService {
  final Ref ref;
  WebSearchService(this.ref);

  Future<String> searchSummary(String query) async {
    final s = ref.read(webSearchSettingsProvider);
    final url = s.endpoint.replaceAll('{q}', Uri.encodeQueryComponent(query));
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      return '搜索失败: ${resp.statusCode}';
    }
    try {
      final map = jsonDecode(resp.body) as Map<String, dynamic>;
      final abstract = map['AbstractText'] as String?;
      if (abstract != null && abstract.isNotEmpty) return abstract;
    } catch (_) {
      // ignore parse errors
    }
    return resp.body.length > 400 ? resp.body.substring(0, 400) + '…' : resp.body;
  }
}

final webSearchServiceProvider = Provider<WebSearchService>((ref) => WebSearchService(ref));
