import '../data/boxes.dart';

class PrefsService {
  static const currentTopicKey = 'topic.current_id';

  String? getCurrentTopicId() => Boxes.prefs.get(currentTopicKey) as String?;
  Future<void> setCurrentTopicId(String id) => Boxes.prefs.put(currentTopicKey, id);

  String? getString(String key) => Boxes.prefs.get(key) as String?;
  Future<void> setString(String key, String value) => Boxes.prefs.put(key, value);

  double? getDouble(String key) => Boxes.prefs.get(key) as double?;
  Future<void> setDouble(String key, double value) => Boxes.prefs.put(key, value);

  Future<void> remove(String key) => Boxes.prefs.delete(key);
}

final prefsService = PrefsService();
