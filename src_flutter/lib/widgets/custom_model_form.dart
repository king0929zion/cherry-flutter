import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/model.dart';
import '../theme/tokens.dart';
import '../utils/ids.dart';

class CustomModelForm extends ConsumerStatefulWidget {
  final AIModel? model;
  final Function(AIModel) onSave;

  const CustomModelForm({
    super.key,
    this.model,
    required this.onSave,
  });

  @override
  ConsumerState<CustomModelForm> createState() => _CustomModelFormState();
}

class _CustomModelFormState extends ConsumerState<CustomModelForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _providerController;
  late TextEditingController _descriptionController;
  late TextEditingController _contextLengthController;
  late TextEditingController _maxTokensController;
  late TextEditingController _inputPriceController;
  late TextEditingController _outputPriceController;
  
  final Set<String> _selectedCapabilities = {};

  static const List<String> _availableCapabilities = [
    'text',
    'vision',
    'function_calling',
    'code_generation',
  ];

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.model?.id ?? '');
    _nameController = TextEditingController(text: widget.model?.name ?? '');
    _providerController = TextEditingController(text: widget.model?.provider ?? '');
    _descriptionController = TextEditingController(text: widget.model?.description ?? '');
    _contextLengthController = TextEditingController(
      text: widget.model?.contextLength.toString() ?? '4096',
    );
    _maxTokensController = TextEditingController(
      text: widget.model?.maxTokens.toString() ?? '4096',
    );
    _inputPriceController = TextEditingController(
      text: widget.model?.inputPrice.toString() ?? '0.0',
    );
    _outputPriceController = TextEditingController(
      text: widget.model?.outputPrice.toString() ?? '0.0',
    );
    
    if (widget.model != null) {
      _selectedCapabilities.addAll(widget.model!.capabilities);
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _providerController.dispose();
    _descriptionController.dispose();
    _contextLengthController.dispose();
    _maxTokensController.dispose();
    _inputPriceController.dispose();
    _outputPriceController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final model = AIModel(
      id: _idController.text.trim().isEmpty 
          ? (widget.model?.id ?? newId()) 
          : _idController.text.trim(),
      name: _nameController.text.trim(),
      provider: _providerController.text.trim().isEmpty 
          ? 'custom' 
          : _providerController.text.trim(),
      description: _descriptionController.text.trim(),
      contextLength: int.tryParse(_contextLengthController.text) ?? 4096,
      maxTokens: int.tryParse(_maxTokensController.text) ?? 4096,
      inputPrice: double.tryParse(_inputPriceController.text) ?? 0.0,
      outputPrice: double.tryParse(_outputPriceController.text) ?? 0.0,
      capabilities: _selectedCapabilities.toList(),
      isAvailable: true,
    );

    widget.onSave(model);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.model == null ? '添加自定义模型' : '编辑模型',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    tooltip: '关闭',
                  ),
                ],
              ),
            ),
            
            // 表单内容
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // 基本信息
                    _SectionCard(
                      title: '基本信息',
                      children: [
                        _TextFormField(
                          controller: _nameController,
                          label: '模型名称',
                          hintText: '例如: gpt-4o-custom',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '请输入模型名称';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _TextFormField(
                          controller: _providerController,
                          label: '供应商',
                          hintText: '例如: openai, anthropic',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '请输入供应商';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _TextFormField(
                          controller: _descriptionController,
                          label: '描述',
                          hintText: '模型功能描述（可选）',
                          maxLines: 3,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 技术规格
                    _SectionCard(
                      title: '技术规格',
                      children: [
                        _TextFormField(
                          controller: _contextLengthController,
                          label: '上下文长度',
                          hintText: '例如: 128000',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '请输入上下文长度';
                            }
                            final number = int.tryParse(value);
                            if (number == null || number <= 0) {
                              return '请输入有效的数字';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _TextFormField(
                          controller: _maxTokensController,
                          label: '最大输出长度',
                          hintText: '例如: 4096',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '请输入最大输出长度';
                            }
                            final number = int.tryParse(value);
                            if (number == null || number <= 0) {
                              return '请输入有效的数字';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 定价信息
                    _SectionCard(
                      title: '定价信息',
                      children: [
                        _TextFormField(
                          controller: _inputPriceController,
                          label: '输入价格',
                          hintText: '例如: 0.005',
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return null;
                            final price = double.tryParse(value);
                            if (price == null || price < 0) {
                              return '请输入有效的价格';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _TextFormField(
                          controller: _outputPriceController,
                          label: '输出价格',
                          hintText: '例如: 0.015',
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return null;
                            final price = double.tryParse(value);
                            if (price == null || price < 0) {
                              return '请输入有效的价格';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 能力标签
                    _SectionCard(
                      title: '模型能力',
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableCapabilities.map((capability) {
                            final isSelected = _selectedCapabilities.contains(capability);
                            return FilterChip(
                              label: Text(_getCapabilityDisplayName(capability)),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedCapabilities.add(capability);
                                  } else {
                                    _selectedCapabilities.remove(capability);
                                  }
                                });
                              },
                              backgroundColor: isDark ? Tokens.surfaceDark : Tokens.surfaceLight,
                              selectedColor: theme.colorScheme.primary.withOpacity(0.1),
                              checkmarkColor: theme.colorScheme.primary,
                              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected ? theme.colorScheme.primary : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 保存按钮
                    FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.model == null ? '添加模型' : '保存修改',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCapabilityDisplayName(String capability) {
    switch (capability) {
      case 'text':
        return '文本处理';
      case 'vision':
        return '视觉理解';
      case 'function_calling':
        return '函数调用';
      case 'code_generation':
        return '代码生成';
      default:
        return capability;
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Tokens.cardDark : Tokens.cardLight,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _TextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;

  const _TextFormField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.validator,
    this.keyboardType,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1,
              ),
            ),
            filled: true,
            fillColor: isDark ? Tokens.surfaceDark : Tokens.surfaceLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}