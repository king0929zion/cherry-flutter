import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/prefs_service.dart';

class WebSearchSettings {
  final String endpoint; // e.g., https://api.duckduckgo.com/?q={q}&format=json
  const WebSearchSettings({this.endpoint = 'https://api.duckduckgo.com/?q={q}&format=json'});

  WebSearchSettings copyWith({String? endpoint}) => WebSearchSettings(endpoint: endpoint ?? this.endpoint);
}

class WebSearchSettingsNotifier extends StateNotifier<WebSearchSettings> {
  WebSearchSettingsNotifier() : super(const WebSearchSettings()) {
    load();
  }

  static const _kEndpoint = 'websearch.endpoint';

  Future<void> load() async {
    state = WebSearchSettings(endpoint: prefsService.getString(_kEndpoint) ?? state.endpoint);
  }

  Future<void> update(WebSearchSettings next) async {
    state = next;
    await prefsService.setString(_kEndpoint, next.endpoint);
  }
}

final webSearchSettingsProvider = StateNotifierProvider<WebSearchSettingsNotifier, WebSearchSettings>((ref) {
  return WebSearchSettingsNotifier();
});
