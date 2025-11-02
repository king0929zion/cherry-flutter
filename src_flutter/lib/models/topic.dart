import 'package:hive/hive.dart';

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

  TopicModel copyWith({
    String? id,
    String? assistantId,
    String? name,
    int? createdAt,
    int? updatedAt,
    bool? isLoading,
  }) {
    return TopicModel(
      id: id ?? this.id,
      assistantId: assistantId ?? this.assistantId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Backward-compat alias
typedef Topic = TopicModel;
