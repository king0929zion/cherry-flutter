import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/boxes.dart';
import '../utils/ids.dart';

class Assistant {
  final String id;
  final String name;
  final String? prompt;
  final String? emoji;
  final String? description;
  final List<String>? tags;
  final List<String>? group;
  
  const Assistant({
    required this.id,
    required this.name,
    this.prompt,
    this.emoji,
    this.description,
    this.tags,
    this.group,
  });

  Assistant copyWith({
    String? name,
    String? prompt,
    String? emoji,
    String? description,
    List<String>? tags,
    List<String>? group,
  }) =>
      Assistant(
        id: id,
        name: name ?? this.name,
        prompt: prompt ?? this.prompt,
        emoji: emoji ?? this.emoji,
        description: description ?? this.description,
        tags: tags ?? this.tags,
        group: group ?? this.group,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (prompt != null) 'prompt': prompt,
        if (emoji != null) 'emoji': emoji,
        if (description != null) 'description': description,
        if (tags != null) 'tags': tags,
        if (group != null) 'group': group,
      };

  static Assistant fromJson(Map m) => Assistant(
        id: m['id'] as String,
        name: m['name'] as String,
        prompt: m['prompt'] as String?,
        emoji: m['emoji'] as String?,
        description: m['description'] as String?,
        tags: m['tags'] != null ? List<String>.from(m['tags'] as List) : null,
        group: m['group'] != null ? List<String>.from(m['group'] as List) : null,
      );
}

class AssistantService {
  Future<List<Assistant>> getAssistants() async {
    final vals = Boxes.prefs.get('assistants') as List? ?? [];
    return vals.map((e) => Assistant.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> saveAssistants(List<Assistant> list) async {
    await Boxes.prefs.put('assistants', list.map((e) => e.toJson()).toList());
  }

  Future<Assistant> createAssistant() async {
    final list = await getAssistants();
    final a = Assistant(
      id: newId(),
      name: '新助手',
      emoji: '🤖',
    );
    list.add(a);
    await saveAssistants(list);
    return a;
  }

  Future<Assistant?> getAssistant(String id) async {
    final list = await getAssistants();
    for (final a in list) {
      if (a.id == id) return a;
    }
    return null;
  }
}

final assistantServiceProvider = Provider<AssistantService>((ref) => AssistantService());

final assistantsProvider = FutureProvider<List<Assistant>>((ref) async {
  return ref.read(assistantServiceProvider).getAssistants();
});
