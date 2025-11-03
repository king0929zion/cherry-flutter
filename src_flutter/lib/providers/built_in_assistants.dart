import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assistant.dart';
import '../providers/locale.dart';
import '../services/built_in_assistants_loader.dart';

// 助手市场使用的内置助手列表（从资产加载，按语言）
final builtInAssistantsProvider = FutureProvider<List<AssistantModel>>((ref) async {
  final locale = ref.watch(localeProvider);
  final code = (locale?.languageCode ?? 'zh');
  return builtInAssistantsLoader.load(code);
});
