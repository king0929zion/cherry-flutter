import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'locale.dart';
import '../services/assistant_service.dart';

final builtInAssistantsProvider = FutureProvider<List<Assistant>>((ref) async {
  final locale = ref.watch(localeProvider);
  final languageCode = locale?.languageCode ?? 'zh';
  return ref.read(assistantServiceProvider).getBuiltInAssistants(languageCode);
});
