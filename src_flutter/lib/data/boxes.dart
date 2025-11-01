import 'package:hive_flutter/hive_flutter.dart';

class Boxes {
  static late Box<Map> messages; // key: messageId, value: message json
  static late Box<Map> topics;   // key: topicId, value: topic json
  static late Box prefs;         // key: string, value: dynamic
  static late Box<Map> blocks;   // key: blockId, value: block json

  static Future<void> openAll() async {
    prefs = await Hive.openBox('prefs');
    topics = await Hive.openBox<Map>('topics');
    messages = await Hive.openBox<Map>('messages');
    blocks = await Hive.openBox<Map>('blocks');
  }
}
