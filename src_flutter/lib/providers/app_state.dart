import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final welcomeShownProvider = NotifierProvider<WelcomeNotifier, bool>(WelcomeNotifier.new);

class WelcomeNotifier extends Notifier<bool> {
  bool _loaded = false;
  @override
  bool build() {
    if (!_loaded) {
      _loaded = true;
      _load();
    }
    return true; // 默认已展示，避免首屏白屏
  }

  static const _key = 'welcome_shown';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> setShown([bool value = true]) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}
