import 'package:json_annotation/json_annotation.dart';

part 'mcp.g.dart';

enum McpServerType {
  streamableHttp,
  sse,
}

@JsonSerializable()
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

  factory McpServer.fromJson(Map<String, dynamic> json) => _$McpServerFromJson(json);
  Map<String, dynamic> toJson() => _$McpServerToJson(this);

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

@JsonSerializable()
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

  factory McpTool.fromJson(Map<String, dynamic> json) => _$McpToolFromJson(json);
  Map<String, dynamic> toJson() => _$McpToolToJson(this);
}