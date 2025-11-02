import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/assistant.dart';

class BuiltInAssistantsLoader {
  static const _zhAsset = 'assets/data/assistants-zh.json';
  static const _enAsset = 'assets/data/assistants-en.json';

  final Map<String, List<Assistant>> _cache = {};

  Future<List<Assistant>> load(String languageCode) async {
    final key = languageCode.startsWith('en') ? 'en' : 'zh';
    if (_cache.containsKey(key)) return _cache[key]!;

    final assetPath = key == 'en' ? _enAsset : _zhAsset;
    final jsonStr = await rootBundle.loadString(assetPath);
    final data = jsonDecode(jsonStr) as List;
    final list = data
        .map((e) => Assistant.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
    _cache[key] = list;
    return list;
  }
}

final builtInAssistantsLoader = BuiltInAssistantsLoader();
