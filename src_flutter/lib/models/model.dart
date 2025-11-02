// Manual JSON serialization, no code generation required
class AIModel {
  final String id;
  final String name;
  final String provider;
  final String description;
  final int contextLength;
  final int maxTokens;
  final double inputPrice;
  final double outputPrice;
  final List<String> capabilities;
  final bool isAvailable;

  const AIModel({
    required this.id,
    required this.name,
    required this.provider,
    this.description = '',
    this.contextLength = 4096,
    this.maxTokens = 4096,
    this.inputPrice = 0.0,
    this.outputPrice = 0.0,
    this.capabilities = const [],
    this.isAvailable = true,
  });

  factory AIModel.fromJson(Map<String, dynamic> json) {
    return AIModel(
      id: json['id'] as String,
      name: json['name'] as String,
      provider: json['provider'] as String,
      description: (json['description'] as String?) ?? '',
      contextLength: (json['contextLength'] as int?) ?? (json['context_length'] as int?) ?? 4096,
      maxTokens: (json['maxTokens'] as int?) ?? (json['max_tokens'] as int?) ?? 4096,
      inputPrice: (json['inputPrice'] as num?)?.toDouble() ?? (json['input_price'] as num?)?.toDouble() ?? 0.0,
      outputPrice: (json['outputPrice'] as num?)?.toDouble() ?? (json['output_price'] as num?)?.toDouble() ?? 0.0,
      capabilities: (json['capabilities'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      isAvailable: (json['isAvailable'] as bool?) ?? (json['is_available'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'provider': provider,
      'description': description,
      'contextLength': contextLength,
      'maxTokens': maxTokens,
      'inputPrice': inputPrice,
      'outputPrice': outputPrice,
      'capabilities': capabilities,
      'isAvailable': isAvailable,
    };
  }

  AIModel copyWith({
    String? id,
    String? name,
    String? provider,
    String? description,
    int? contextLength,
    int? maxTokens,
    double? inputPrice,
    double? outputPrice,
    List<String>? capabilities,
    bool? isAvailable,
  }) {
    return AIModel(
      id: id ?? this.id,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      description: description ?? this.description,
      contextLength: contextLength ?? this.contextLength,
      maxTokens: maxTokens ?? this.maxTokens,
      inputPrice: inputPrice ?? this.inputPrice,
      outputPrice: outputPrice ?? this.outputPrice,
      capabilities: capabilities ?? this.capabilities,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  String get displayName {
    final parts = name.split('/');
    return parts.length > 1 ? parts.last : name;
  }

  String get providerName {
    switch (provider.toLowerCase()) {
      case 'openai':
        return 'OpenAI';
      case 'anthropic':
        return 'Anthropic';
      case 'google':
        return 'Google';
      case 'azure':
        return 'Azure OpenAI';
      default:
        return provider;
    }
  }
}