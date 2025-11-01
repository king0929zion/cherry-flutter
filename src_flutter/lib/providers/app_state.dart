import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final welcomeShownProvider = StateNotifierProvider<WelcomeNotifier, bool>((ref) {
  return WelcomeNotifier()..load();
});

class WelcomeNotifier extends StateNotifier<bool> {
  WelcomeNotifier() : super(true); // 默认已展示，避免首屏白屏

  static const _key = 'welcome_shown';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> setShown([bool value = true]) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}
