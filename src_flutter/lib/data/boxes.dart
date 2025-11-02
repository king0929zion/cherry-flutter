import 'package:hive/hive.dart';
import '../models/models.dart';

// Simple boxes facade used across the app. Stores plain Map data to avoid
// requiring generated Hive TypeAdapters during build.
class Boxes {
  static late Box topics;
  static late Box assistants;
  static late Box messages;
  static late Box blocks;
  static late Box prefs;

  static Future<void> openAll() async {
    topics = await Hive.openBox('topics');
    assistants = await Hive.openBox('assistants');
    messages = await Hive.openBox('messages');
    blocks = await Hive.openBox('message_blocks');
    prefs = await Hive.openBox('settings');
  }
}

// Backward-compatible typed boxes interface used by some services.
class HiveBoxes {
  static const String topicsBox = 'topics';
  static const String assistantsBox = 'assistants';
  static const String messagesBox = 'messages';
  static const String messageBlocksBox = 'message_blocks';
  static const String settingsBox = 'settings';

  static Future<void> openBoxes() async {
    await Hive.openBox<TopicModel>(topicsBox);
    await Hive.openBox<AssistantModel>(assistantsBox);
    await Hive.openBox<MessageModel>(messagesBox);
    await Hive.openBox<MessageBlockModel>(messageBlocksBox);
    await Hive.openBox(settingsBox);
  }

  static Box<TopicModel> getTopicsBox() => Hive.box<TopicModel>(topicsBox);
  static Box<AssistantModel> getAssistantsBox() => Hive.box<AssistantModel>(assistantsBox);
  static Box<MessageModel> getMessagesBox() => Hive.box<MessageModel>(messagesBox);
  static Box<MessageBlockModel> getMessageBlocksBox() => Hive.box<MessageBlockModel>(messageBlocksBox);
  static Box getSettingsBox() => Hive.box(settingsBox);
}