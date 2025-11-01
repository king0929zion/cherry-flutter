import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/prefs_service.dart';

class WebSearchSettings {
  final String endpoint; // e.g., https://api.duckduckgo.com/?q={q}&format=json
  const WebSearchSettings({this.endpoint = 'https://api.duckduckgo.com/?q={q}&format=json'});

  WebSearchSettings copyWith({String? endpoint}) => WebSearchSettings(endpoint: endpoint ?? this.endpoint);
}

class WebSearchSettingsNotifier extends Notifier<WebSearchSettings> {
  @override
  WebSearchSettings build() {
    _load();
    return const WebSearchSettings();
  }

  static const _kEndpoint = 'websearch.endpoint';

  Future<void> _load() async {
    state = WebSearchSettings(endpoint: prefsService.getString(_kEndpoint) ?? state.endpoint);
  }

  Future<void> update(WebSearchSettings next) async {
    state = next;
    await prefsService.setString(_kEndpoint, next.endpoint);
  }
}

final webSearchSettingsProvider = NotifierProvider<WebSearchSettingsNotifier, WebSearchSettings>(
  WebSearchSettingsNotifier.new,
);
