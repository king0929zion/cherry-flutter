// Manual JSON serialization for ToolCall models

enum ToolCallStatus {
  pending,
  inProgress,
  done,
  error,
}

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

  factory ToolCall.fromJson(Map<String, dynamic> json) {
    return ToolCall(
      id: json['id'] as String,
      name: json['name'] as String,
      arguments: (json['arguments'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      status: _parseStatus(json['status'] as String),
      response: json['response'],
      error: json['error'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')
          ?? DateTime.fromMillisecondsSinceEpoch((json['created_at'] as int?) ?? DateTime.now().millisecondsSinceEpoch),
      completedAt: (json['completedAt'] as String?) != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : (json['completed_at'] as int?) != null
              ? DateTime.fromMillisecondsSinceEpoch(json['completed_at'] as int)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arguments': arguments,
      'status': status.name,
      'response': response,
      'error': error,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  static ToolCallStatus _parseStatus(String value) {
    switch (value) {
      case 'pending':
        return ToolCallStatus.pending;
      case 'inProgress':
      case 'in_progress':
        return ToolCallStatus.inProgress;
      case 'done':
      case 'completed':
        return ToolCallStatus.done;
      case 'error':
        return ToolCallStatus.error;
      default:
        return ToolCallStatus.pending;
    }
  }

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

  factory ToolCallBlock.fromJson(Map<String, dynamic> json) {
    return ToolCallBlock(
      id: json['id'] as String,
      messageId: json['messageId'] as String? ?? json['message_id'] as String,
      toolCall: ToolCall.fromJson(json['toolCall'] as Map<String, dynamic>? ?? json['tool_call'] as Map<String, dynamic>),
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messageId': messageId,
      'toolCall': toolCall.toJson(),
      'metadata': metadata,
    };
  }
}