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

  static Topic fromJson(Map<dynamic, dynamic> json) => Topic(
        id: json['id'] as String,
        assistantId: json['assistantId'] as String,
        name: json['name'] as String,
        createdAt: (json['createdAt'] as num).toInt(),
        updatedAt: (json['updatedAt'] as num).toInt(),
        isLoading: (json['isLoading'] as bool?) ?? false,
      );
}

class TopicService {
  final _listeners = <void Function()>{};
  final PrefsService _prefs;

  TopicService(this._prefs);

  Future<Topic> ensureDefaultTopic() async {
    final currentId = _prefs.getCurrentTopicId();
    if (currentId != null) {
      final existing = await getTopicById(currentId);
      if (existing != null) return existing;
    }

    final topic = Topic(
      id: newId(),
      assistantId: 'default',
      name: '新主题',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await Boxes.topics.put(topic.id, topic.toJson());
    await _prefs.setCurrentTopicId(topic.id);
    _notify();
    return topic;
  }

  Future<Topic?> getTopicById(String id) async {
    final raw = Boxes.topics.get(id) as Map?;
    return raw == null ? null : Topic.fromJson(raw);
  }

  Future<List<Topic>> getTopics() async {
    return Boxes.topics.values.map((e) => Topic.fromJson(e as Map)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<Topic> createTopic({String assistantId = 'default', String name = '新主题'}) async {
    final topic = Topic(
      id: newId(),
      assistantId: assistantId,
      name: name,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await Boxes.topics.put(topic.id, topic.toJson());
    await _prefs.setCurrentTopicId(topic.id);
    _notify();
    return topic;
  }

  Future<void> renameTopic(String id, String name) async {
    final topic = await getTopicById(id);
    if (topic == null) return;
    final updated = topic.copyWith(
      name: name,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await Boxes.topics.put(id, updated.toJson());
    _notify();
  }

  Future<void> deleteTopic(String id) async {
    await Boxes.topics.delete(id);
    final toDelete = Boxes.messages.keys.where((key) {
      final entry = Boxes.messages.get(key) as Map?;
      return entry != null && entry['topicId'] == id;
    }).toList();
    for (final key in toDelete) {
      await Boxes.messages.delete(key);
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
    for (final listener in _listeners) {
      listener();
    }
  }
}

final topicServiceProvider = Provider<TopicService>((ref) => TopicService(prefsService));

final topicsProvider = StreamProvider<List<Topic>>((ref) async* {
    final svc = ref.read(topicServiceProvider);
    final controller = StreamController<List<Topic>>();
    Future<void> push() async => controller.add(await svc.getTopics());
    svc.addListener(push);
    ref.onDispose(() {
      svc.removeListener(push);
      controller.close();
    });
    await push();
    yield* controller.stream;
  });

final currentTopicProvider = FutureProvider<Topic>((ref) async {
  final svc = ref.read(topicServiceProvider);
  return svc.ensureDefaultTopic();
});
