import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/boxes.dart';
import '../utils/ids.dart';
import 'prefs_service.dart';

class Topic {
  final String id;
  final String assistantId;
  final String name;
  final int createdAt;
  final int updatedAt;
  final bool isLoading;

  Topic({
    required this.id,
    required this.assistantId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.isLoading = false,
  });

  Topic copyWith({String? name, bool? isLoading, int? updatedAt}) => Topic(
        id: id,
        assistantId: assistantId,
        name: name ?? this.name,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isLoading: isLoading ?? this.isLoading,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'assistantId': assistantId,
        'name': name,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'isLoading': isLoading,
      };

  static Topic fromJson(Map m) => Topic(
        id: m['id'] as String,
        assistantId: m['assistantId'] as String,
        name: m['name'] as String,
        createdAt: (m['createdAt'] as num).toInt(),
        updatedAt: (m['updatedAt'] as num).toInt(),
        isLoading: (m['isLoading'] as bool?) ?? false,
      );
}

class TopicService {
  final _listeners = <void Function()>{};
  final PrefsService _prefs;

  TopicService(this._prefs);

  Future<Topic> ensureDefaultTopic() async {
    final currentId = _prefs.getCurrentTopicId();
    if (currentId != null) {
      final t = await getTopicById(currentId);
      if (t != null) return t;
    }

    final newTopic = Topic(
      id: newId(),
      assistantId: 'default',
      name: '新主题',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await Boxes.topics.put(newTopic.id, newTopic.toJson());
    await _prefs.setCurrentTopicId(newTopic.id);
    _notify();
    return newTopic;
  }

  Future<Topic?> getTopicById(String id) async {
    final m = Boxes.topics.get(id) as Map?;
    return m == null ? null : Topic.fromJson(m);
  }

  Future<List<Topic>> getTopics() async {
    return Boxes.topics.values.map((e) => Topic.fromJson(e as Map)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<Topic> createTopic({String assistantId = 'default', String name = '新主题'}) async {
    final t = Topic(
      id: newId(),
      assistantId: assistantId,
      name: name,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await Boxes.topics.put(t.id, t.toJson());
    await _prefs.setCurrentTopicId(t.id);
    _notify();
    return t;
  }

  Future<void> renameTopic(String id, String name) async {
    final t = await getTopicById(id);
    if (t == null) return;
    final updated = t.copyWith(name: name, updatedAt: DateTime.now().millisecondsSinceEpoch);
    await Boxes.topics.put(id, updated.toJson());
    _notify();
  }

  Future<void> deleteTopic(String id) async {
    await Boxes.topics.delete(id);
    // purge messages of this topic
    final toDelete = Boxes.messages.keys.where((k) {
      final m = Boxes.messages.get(k) as Map?;
      return m != null && m['topicId'] == id;
    }).toList();
    for (final k in toDelete) {
      await Boxes.messages.delete(k);
    }
    if (_prefs.getCurrentTopicId() == id) {
      await ensureDefaultTopic();
    }
    _notify();
  }

  String? get currentTopicId => _prefs.getCurrentTopicId();
  Future<void> setCurrentTopic(String id) => _prefs.setCurrentTopicId(id);

  void addListener(void Function() cb) => _listeners.add(cb);
  void removeListener(void Function() cb) => _listeners.remove(cb);
  void _notify() {
    for (final l in _listeners) l();
  }
}

final topicServiceProvider = Provider<TopicService>((ref) => TopicService(prefsService));

final topicsProvider = StreamProvider<List<Topic>>((ref) async* {
  final svc = ref.read(topicServiceProvider);
  final controller = StreamController<List<Topic>>();
  void push() async => controller.add(await svc.getTopics());
  svc.addListener(push);
  ref.onDispose(() {
    svc.removeListener(push);
    controller.close();
  });
  push();
  yield* controller.stream;
});

final currentTopicProvider = FutureProvider<Topic>((ref) async {
  final svc = ref.read(topicServiceProvider);
  return svc.ensureDefaultTopic();
});
