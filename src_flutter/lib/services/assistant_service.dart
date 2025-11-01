import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/boxes.dart';
import '../utils/ids.dart';
import 'built_in_assistants_loader.dart';

class Assistant {
  final String id;
  final String name;
  final String? prompt;
  final String? emoji;
  final String? description;
  final List<String>? tags;
  final List<String>? group;
  final String? type;
  final Map<String, dynamic>? settings;
  final Map<String, dynamic>? model;
  final List<String>? topics;

  const Assistant({
    required this.id,
    required this.name,
    this.prompt,
    this.emoji,
    this.description,
    this.tags,
    this.group,
    this.type,
    this.settings,
    this.model,
    this.topics,
  });

  Assistant copyWith({
    String? id,
    String? name,
    String? prompt,
    String? emoji,
    String? description,
    List<String>? tags,
    List<String>? group,
    String? type,
    Map<String, dynamic>? settings,
    Map<String, dynamic>? model,
    List<String>? topics,
  }) =>
      Assistant(
        id: id ?? this.id,
        name: name ?? this.name,
        prompt: prompt ?? this.prompt,
        emoji: emoji ?? this.emoji,
        description: description ?? this.description,
        tags: tags ?? this.tags,
        group: group ?? this.group,
        type: type ?? this.type,
        settings: settings ?? this.settings,
        model: model ?? this.model,
        topics: topics ?? this.topics,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (prompt != null) 'prompt': prompt,
        if (emoji != null) 'emoji': emoji,
        if (description != null) 'description': description,
        if (tags != null) 'tags': tags,
        if (group != null) 'group': group,
        if (type != null) 'type': type,
        if (settings != null) 'settings': settings,
        if (model != null) 'model': model,
        if (topics != null) 'topics': topics,
      };

  static Assistant fromJson(Map m) => Assistant(
        id: m['id']?.toString() ?? '',
        name: (m['name'] ?? '') as String,
        prompt: m['prompt'] as String?,
        emoji: m['emoji'] as String?,
        description: m['description'] as String?,
        tags: m['tags'] != null
            ? List<String>.from((m['tags'] as List).map((e) => e.toString()))
            : null,
        group: m['group'] != null
            ? List<String>.from((m['group'] as List).map((e) => e.toString()))
            : null,
        type: m['type'] as String?,
        settings:
            m['settings'] != null ? Map<String, dynamic>.from(m['settings'] as Map) : null,
        model: m['model'] != null ? Map<String, dynamic>.from(m['model'] as Map) : null,
        topics: m['topics'] != null
            ? List<String>.from((m['topics'] as List).map((e) => e.toString()))
            : null,
      );
}

﻿class AssistantService {
  static const String _assistantsKey = 'assistants';
  static const Map<String, String> assignmentKeys = {
    'default': 'assistant.assign.default',
    'quick': 'assistant.assign.quick',
    'translate': 'assistant.assign.translate',
  };

  static const List<Assistant> _systemAssistants = [
    Assistant(
      id: 'default',
      name: '默认助手',
      emoji: '🤖',
      description: '适用于日常对话的通用助手。',
      prompt: '你是 Cherry Studio 的默认助手，需要提供准确、有帮助、友善的回答。',
      tags: ['默认', '通用'],
      type: 'system',
    ),
    Assistant(
      id: 'quick',
      name: '快速助手',
      emoji: '⚡',
      description: '针对快速问答场景，回复更简洁直接。',
      prompt: '你是一个反应迅速的助手，回答要点即可，尽量控制在两句话内。',
      tags: ['快捷', '效率'],
      type: 'system',
    ),
    Assistant(
      id: 'translate',
      name: '翻译助手',
      emoji: '🌐',
      description: '专注于中英文互译与润色。',
      prompt: '你是专业的翻译助手，请提供自然、准确的双语翻译，并保持原意。',
      tags: ['翻译', '语言'],
      type: 'system',
    ),
  ];

  Future<List<Assistant>> getAssistants() async {
    final raw = Boxes.prefs.get(_assistantsKey) as List? ?? [];
    final Map<String, Assistant> byId = {
      for (final item in raw)
        (item as Map)['id'] as String:
            Assistant.fromJson(Map<String, dynamic>.from(item as Map)),
    };

    var changed = false;
    for (final builtIn in _systemAssistants) {
      final existing = byId[builtIn.id];
      if (existing == null) {
        byId[builtIn.id] = builtIn;
        changed = true;
      } else {
        byId[builtIn.id] = existing.copyWith(
          name: existing.name.isEmpty ? builtIn.name : existing.name,
          emoji: existing.emoji ?? builtIn.emoji,
          description: existing.description ?? builtIn.description,
          prompt: existing.prompt ?? builtIn.prompt,
          tags: existing.tags ?? builtIn.tags,
          type: existing.type ?? builtIn.type,
        );
      }
    }

    final ordered = <Assistant>[];
    for (final builtIn in _systemAssistants) {
      final assistant = byId.remove(builtIn.id);
      if (assistant != null) ordered.add(assistant);
    }
    ordered.addAll(byId.values);

    if (changed || ordered.length != raw.length) {
      await saveAssistants(ordered);
    }

    return ordered;
  }

  Future<void> saveAssistants(List<Assistant> list) async {
    await Boxes.prefs.put(
      _assistantsKey,
      list.map((assistant) => assistant.toJson()).toList(),
    );
  }

  Future<Assistant> createAssistant({Assistant? template}) async {
    final list = await getAssistants();
    final assistant = Assistant(
      id: template?.id ?? newId(),
      name: template?.name ?? '新助手',
      emoji: template?.emoji ?? '🤖',
      description: template?.description,
      prompt: template?.prompt,
      tags: template?.tags,
      group: template?.group,
      type: template?.type ?? 'external',
      settings: template?.settings,
      model: template?.model,
      topics: template?.topics,
    );
    list.add(assistant);
    await saveAssistants(list);
    return assistant;
  }

  Future<Assistant?> getAssistant(String id) async {
    final list = await getAssistants();
    for (final assistant in list) {
      if (assistant.id == id) return assistant;
    }
    return null;
  }

  Future<List<Assistant>> getBuiltInAssistants(String languageCode) async {
    final list = await builtInAssistantsLoader.load(languageCode);
    return list
        .map((assistant) => assistant.copyWith(type: assistant.type ?? 'builtIn'))
        .toList(growable: false);
  }

  Future<Assistant> importBuiltInAssistant(Assistant assistant) async {
    return createAssistant(
      template: assistant.copyWith(
        id: newId(),
        type: 'external',
      ),
    );
  }

  Map<String, String?> readAssignments() {
    return {
      for (final entry in assignmentKeys.entries)
        entry.key: Boxes.prefs.get(entry.value) as String?,
    };
  }

  Future<void> ensureAssignments(List<Assistant> assistants) async {
    if (assistants.isEmpty) return;
    final ids = assistants.map((e) => e.id).toSet();
    for (final entry in assignmentKeys.entries) {
      final current = Boxes.prefs.get(entry.value) as String?;
      if (current == null || !ids.contains(current)) {
        final fallback = ids.contains(entry.key) ? entry.key : assistants.first.id;
        await Boxes.prefs.put(entry.value, fallback);
      }
    }
  }

  Future<void> assign(String role, String assistantId) async {
    final key = assignmentKeys[role];
    if (key == null) return;
    await Boxes.prefs.put(key, assistantId);
  }
}
final assistantServiceProvider = Provider<AssistantService>((ref) => AssistantService());

final assistantsProvider = FutureProvider<List<Assistant>>((ref) async {
  return ref.read(assistantServiceProvider).getAssistants();
});
