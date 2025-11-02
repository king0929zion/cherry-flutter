import 'package:flutter/material.dart';

IconData getModelOrProviderIcon(String modelId, String provider, bool isDark) {
  // 根据供应商返回对应的图标
  switch (provider.toLowerCase()) {
    case 'openai':
      return Icons.psychology_outlined; // OpenAI 图标
    case 'anthropic':
      return Icons.smart_toy_outlined; // Claude 图标
    case 'google':
      return Icons.cloud_outlined; // Gemini 图标
    case 'azure':
      return Icons.business_outlined; // Azure 图标
    default:
      return Icons.memory_outlined; // 默认 AI 图标
  }
}

IconData getCapabilityIcon(String capability) {
  switch (capability) {
    case 'text':
      return Icons.text_fields_outlined;
    case 'vision':
      return Icons.visibility_outlined;
    case 'function_calling':
      return Icons.code_outlined;
    case 'code_generation':
      return Icons.code_outlined;
    default:
      return Icons.settings_outlined;
  }
}