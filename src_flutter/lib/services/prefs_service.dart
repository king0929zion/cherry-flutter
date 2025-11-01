import 'package:hive_flutter/hive_flutter.dart';

import '../data/boxes.dart';

class PrefsService {
  static const currentTopicKey = 'topic.current_id';

  String? getCurrentTopicId() => Boxes.prefs.get(currentTopicKey) as String?;
  Future<void> setCurrentTopicId(String id) => Boxes.prefs.put(currentTopicKey, id);
}

final prefsService = PrefsService();
