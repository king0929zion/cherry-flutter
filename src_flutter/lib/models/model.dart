import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
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

  factory AIModel.fromJson(Map<String, dynamic> json) => _$AIModelFromJson(json);
  Map<String, dynamic> toJson() => _$AIModelToJson(this);

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