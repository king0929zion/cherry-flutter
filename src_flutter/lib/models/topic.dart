import 'package:hive/hive.dart';

part 'topic.g.dart';

@HiveType(typeId: 1)
class TopicModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String assistantId;
  @HiveField(2)
  String name;
  @HiveField(3)
  int createdAt;
  @HiveField(4)
  int updatedAt;
  @HiveField(5)
  bool isLoading;

  TopicModel({
    required this.id,
    required this.assistantId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.isLoading = false,
  });
}
