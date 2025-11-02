import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/prefs_service.dart';

class UserSettings {
  final String displayName;
  final String? avatarDataUrl;

  const UserSettings({
    required this.displayName,
    this.avatarDataUrl,
  });

  UserSettings copyWith({
    String? displayName,
    String? avatarDataUrl,
  }) {
    return UserSettings(
      displayName: displayName ?? this.displayName,
      avatarDataUrl: avatarDataUrl,
    );
  }

  Uint8List? get avatarBytes {
    final data = avatarDataUrl;
    if (data == null || data.isEmpty) return null;
    final commaIndex = data.indexOf(',');
    final encoded = commaIndex >= 0 ? data.substring(commaIndex + 1) : data;
    try {
      return base64Decode(encoded);
    } catch (_) {
      return null;
    }
  }
}

class UserSettingsNotifier extends Notifier<UserSettings> {
  static const _kDisplayName = 'user.display_name';
  static const _kAvatar = 'user.avatar_data';

  @override
  UserSettings build() {
    final name = prefsService.getString(_kDisplayName) ?? 'Cherry Studio';
    final avatar = prefsService.getString(_kAvatar);
    return UserSettings(displayName: name, avatarDataUrl: avatar);
  }

  Future<void> updateDisplayName(String name) async {
    final trimmed = name.trim().isEmpty ? 'Cherry Studio' : name.trim();
    state = state.copyWith(displayName: trimmed, avatarDataUrl: state.avatarDataUrl);
    await prefsService.setString(_kDisplayName, trimmed);
  }

  Future<void> updateAvatar(Uint8List? bytes, {String mimeType = 'image/png'}) async {
    if (bytes == null) {
      state = state.copyWith(avatarDataUrl: null);
      await prefsService.remove(_kAvatar);
      return;
    }
    final encoded = base64Encode(bytes);
    final dataUrl = 'data:$mimeType;base64,$encoded';
    state = state.copyWith(avatarDataUrl: dataUrl);
    await prefsService.setString(_kAvatar, dataUrl);
  }
}

final userSettingsProvider =
    NotifierProvider<UserSettingsNotifier, UserSettings>(UserSettingsNotifier.new);
