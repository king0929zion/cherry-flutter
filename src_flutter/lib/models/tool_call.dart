import 'package:json_annotation/json_annotation.dart';

part 'tool_call.g.dart';

enum ToolCallStatus {
  pending,
  inProgress,
  done,
  error,
}

@JsonSerializable()
class ToolCall {
  final String id;
  final String name;
  final Map<String, dynamic> arguments;
  final ToolCallStatus status;
  final dynamic response;
  final String? error;
  final DateTime createdAt;
  final DateTime? completedAt;

  const ToolCall({
    required this.id,
    required this.name,
    required this.arguments,
    required this.status,
    this.response,
    this.error,
    required this.createdAt,
    this.completedAt,
  });

  factory ToolCall.fromJson(Map<String, dynamic> json) => _$ToolCallFromJson(json);
  Map<String, dynamic> toJson() => _$ToolCallToJson(this);

  ToolCall copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? arguments,
    ToolCallStatus? status,
    dynamic response,
    String? error,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return ToolCall(
      id: id ?? this.id,
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
      status: status ?? this.status,
      response: response ?? this.response,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  bool get isPending => status == ToolCallStatus.pending;
  bool get isInProgress => status == ToolCallStatus.inProgress;
  bool get isDone => status == ToolCallStatus.done;
  bool get isError => status == ToolCallStatus.error;
}

@JsonSerializable()
class ToolCallBlock {
  final String id;
  final String messageId;
  final ToolCall toolCall;
  final Map<String, dynamic>? metadata;

  const ToolCallBlock({
    required this.id,
    required this.messageId,
    required this.toolCall,
    this.metadata,
  });

  factory ToolCallBlock.fromJson(Map<String, dynamic> json) => _$ToolCallBlockFromJson(json);
  Map<String, dynamic> toJson() => _$ToolCallBlockToJson(this);
}