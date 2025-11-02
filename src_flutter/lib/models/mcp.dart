// Manual JSON serialization for MCP models

enum McpServerType {
  streamableHttp,
  sse,
}

class McpServer {
  final String id;
  final String name;
  final String? description;
  final String baseUrl;
  final McpServerType type;
  final Map<String, String>? headers;
  final int? timeout;
  final bool isActive;
  final List<String> disabledTools;

  const McpServer({
    required this.id,
    required this.name,
    this.description,
    required this.baseUrl,
    required this.type,
    this.headers,
    this.timeout,
    this.isActive = true,
    this.disabledTools = const [],
  });

  factory McpServer.fromJson(Map<String, dynamic> json) {
    return McpServer(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      baseUrl: json['baseUrl'] as String? ?? json['base_url'] as String,
      type: _parseType(json['type'] as String),
      headers: (json['headers'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())),
      timeout: (json['timeout'] as num?)?.toInt(),
      isActive: (json['isActive'] as bool?) ?? (json['is_active'] as bool?) ?? true,
      disabledTools: (json['disabledTools'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'baseUrl': baseUrl,
      'type': type.name,
      'headers': headers,
      'timeout': timeout,
      'isActive': isActive,
      'disabledTools': disabledTools,
    };
  }

  static McpServerType _parseType(String value) {
    switch (value) {
      case 'streamableHttp':
      case 'streamable_http':
        return McpServerType.streamableHttp;
      case 'sse':
        return McpServerType.sse;
      default:
        return McpServerType.streamableHttp;
    }
  }

  McpServer copyWith({
    String? id,
    String? name,
    String? description,
    String? baseUrl,
    McpServerType? type,
    Map<String, String>? headers,
    int? timeout,
    bool? isActive,
    List<String>? disabledTools,
  }) {
    return McpServer(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseUrl: baseUrl ?? this.baseUrl,
      type: type ?? this.type,
      headers: headers ?? this.headers,
      timeout: timeout ?? this.timeout,
      isActive: isActive ?? this.isActive,
      disabledTools: disabledTools ?? this.disabledTools,
    );
  }
}

class McpTool {
  final String id;
  final String name;
  final String? description;
  final Map<String, dynamic>? inputSchema;

  const McpTool({
    required this.id,
    required this.name,
    this.description,
    this.inputSchema,
  });

  factory McpTool.fromJson(Map<String, dynamic> json) {
    return McpTool(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      inputSchema: json['inputSchema'] as Map<String, dynamic>?
          ?? json['input_schema'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'inputSchema': inputSchema,
    };
  }
}