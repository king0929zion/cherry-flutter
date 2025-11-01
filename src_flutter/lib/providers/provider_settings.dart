import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/prefs_service.dart';

class ProviderSettings {
  final String providerId;
  final String apiKey;
  final String baseUrl;
  final String model;
  final double temperature;

  const ProviderSettings({
    this.providerId = 'openai',
    this.apiKey = '',
    this.baseUrl = 'https://api.openai.com/v1',
    this.model = 'gpt-4o-mini',
    this.temperature = 0.7,
  });

  ProviderSettings copyWith({
    String? providerId,
    String? apiKey,
    String? baseUrl,
    String? model,
    double? temperature,
  }) => ProviderSettings(
        providerId: providerId ?? this.providerId,
        apiKey: apiKey ?? this.apiKey,
        baseUrl: baseUrl ?? this.baseUrl,
        model: model ?? this.model,
        temperature: temperature ?? this.temperature,
      );
}

class ProviderSettingsNotifier extends Notifier<ProviderSettings> {
  @override
  ProviderSettings build() {
    _load();
    return const ProviderSettings();
  }

  static const _kApiKey = 'provider.apiKey';
  static const _kBaseUrl = 'provider.baseUrl';
  static const _kModel = 'provider.model';
  static const _kProviderId = 'provider.id';
  static const _kTemp = 'provider.temperature';

  Future<void> _load() async {
    state = ProviderSettings(
      providerId: prefsService.getString(_kProviderId) ?? 'openai',
      apiKey: prefsService.getString(_kApiKey) ?? '',
      baseUrl: prefsService.getString(_kBaseUrl) ?? 'https://api.openai.com/v1',
      model: prefsService.getString(_kModel) ?? 'gpt-4o-mini',
      temperature: prefsService.getDouble(_kTemp) ?? 0.7,
    );
  }

  Future<void> update(ProviderSettings next) async {
    state = next;
    await prefsService.setString(_kProviderId, next.providerId);
    await prefsService.setString(_kApiKey, next.apiKey);
    await prefsService.setString(_kBaseUrl, next.baseUrl);
    await prefsService.setString(_kModel, next.model);
    await prefsService.setDouble(_kTemp, next.temperature);
  }
}

final providerSettingsProvider = NotifierProvider<ProviderSettingsNotifier, ProviderSettings>(
    ProviderSettingsNotifier.new);
