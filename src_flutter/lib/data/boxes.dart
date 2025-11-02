import 'package:hive/hive.dart';
import '../models/models.dart';

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