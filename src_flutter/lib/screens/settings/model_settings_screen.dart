import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/model_provider.dart';
import '../../providers/provider_settings.dart';
import '../../theme/tokens.dart';
import '../../models/model.dart';
import '../../widgets/model_selector.dart';
import '../../widgets/custom_model_form.dart';
import '../../widgets/header_bar.dart';

class ModelSettingsScreen extends ConsumerWidget {
  const ModelSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final providerSettings = ref.watch(providerSettingsProvider);
    final modelsAsync = ref.watch(modelsProvider);
    final selectedModel = ref.watch(selectedModelProvider);
    final searchQuery = ref.watch(modelSearchProvider);

    return Scaffold(
      backgroundColor: isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HeaderBar(
              title: '模型管理',
              leftButton: HeaderBarButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                ),
                onPress: () => context.pop(),
              ),
              rightButton: HeaderBarButton(
                icon: Icon(
                  Icons.add_outlined,
                  size: 24,
                  color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                ),
                onPress: () => _showAddModelDialog(context, ref),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前模型',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CurrentModelCard(
                      currentModelId: providerSettings.model,
                      settings: providerSettings,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '可用模型',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => ref.invalidate(modelsProvider),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('刷新'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 搜索框
                    _SearchField(
                      value: searchQuery,
                      onChanged: (q) => ref.read(modelSearchProvider.notifier).updateSearch(q),
                    ),
                    const SizedBox(height: 10),
                    // 能力筛选 Chips（本地简易过滤）
                    _CapabilityChips(
                      onChanged: (_) {
                        // 使用简单策略：直接触发重建；过滤在 _ModelsGrid 内处理（基于 search 已过滤的列表）
                      },
                    ),
                    const SizedBox(height: 16),
                    modelsAsync.when(
                      data: (_) {
                        final filtered = ref.watch(filteredModelsProvider);
                        return _ModelsGrid(models: filtered);
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) => _ErrorCard(
                        error: error.toString(),
                        onRetry: () => ref.invalidate(modelsProvider),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '自定义模型',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer(
                      builder: (context, ref, _) {
                        final customModelsAsync = ref.watch(customModelsProvider);
                        return customModelsAsync.when(
                          data: (customModels) => customModels.isEmpty
                              ? _EmptyCustomModelsCard(onAdd: () => _showAddModelDialog(context, ref))
                              : _CustomModelsList(
                                  models: customModels,
                                  onEdit: (model) => _showEditModelDialog(context, ref, model),
                                  onDelete: (model) => _showDeleteModelDialog(context, ref, model),
                                ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => _ErrorCard(
                            error: error.toString(),
                            onRetry: () => ref.invalidate(customModelsProvider),
                          ),
                        );
                      },
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

  void _showAddModelDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomModelForm(
        onSave: (model) async {
          final service = ref.read(modelServiceProvider);
          await service.addCustomModel(model);
          ref.invalidate(customModelsProvider);
          ref.invalidate(modelsProvider);
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('模型已添加')),
            );
          }
        },
      ),
    );
  }

  void _showEditModelDialog(BuildContext context, WidgetRef ref, AIModel model) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomModelForm(
        model: model,
        onSave: (updatedModel) async {
          final service = ref.read(modelServiceProvider);
          await service.updateCustomModel(updatedModel);
          ref.invalidate(customModelsProvider);
          ref.invalidate(modelsProvider);
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('模型已更新')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteModelDialog(BuildContext context, WidgetRef ref, AIModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除模型'),
        content: Text('确定要删除模型 "${model.name}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final service = ref.read(modelServiceProvider);
              await service.removeCustomModel(model.id);
              ref.invalidate(customModelsProvider);
              ref.invalidate(modelsProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('模型已删除')),
                );
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Tokens.cardDark : Tokens.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
        ),
      ),
      child: TextField(
        controller: TextEditingController(text: value),
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
          ),
          hintText: '搜索模型…',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}

class _CapabilityChips extends StatefulWidget {
  final ValueChanged<String?> onChanged;
  const _CapabilityChips({required this.onChanged});

  @override
  State<_CapabilityChips> createState() => _CapabilityChipsState();
}

class _CapabilityChipsState extends State<_CapabilityChips> {
  String? _selected; // text / vision / function_calling / code_generation
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final items = const [
      ['全部', null],
      ['文本', 'text'],
      ['视觉', 'vision'],
      ['函数调用', 'function_calling'],
      ['代码生成', 'code_generation'],
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final label = items[i][0] as String;
          final value = items[i][1] as String?;
          final selected = _selected == value || (_selected == null && value == null);
          final bg = selected ? (isDark ? Tokens.greenDark20 : Tokens.green10) : Colors.transparent;
          final fg = selected ? (isDark ? Tokens.greenDark100 : Tokens.green100) : (isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight);
          final border = selected ? (isDark ? Tokens.greenDark20 : Tokens.green20) : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08));
          return GestureDetector(
            onTap: () {
              setState(() => _selected = value);
              widget.onChanged(value);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: border, width: 0.8),
              ),
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: fg, fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CurrentModelCard extends ConsumerWidget {
  final String currentModelId;
  final ProviderSettings settings;

  const _CurrentModelCard({
    required this.currentModelId,
    required this.settings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final modelsAsync = ref.watch(modelsProvider);

    return modelsAsync.when(
      data: (models) {
        final currentModel = models.where((m) => m.id == currentModelId).firstOrNull;
        
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isDark ? Tokens.blueDark20 : Tokens.blue10,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.smart_toy_outlined,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentModel?.displayName ?? currentModelId,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentModel?.providerName ?? settings.providerId,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? Tokens.textSecondaryDark
                                  : Tokens.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showModelSelector(context, ref),
                      child: const Text('更换'),
                    ),
                  ],
                ),
                if (currentModel != null) ...[
                  const SizedBox(height: 16),
                  _ModelInfoGrid(model: currentModel),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('加载模型信息失败'),
        ),
      ),
    );
  }

  void _showModelSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModelSelector(
        onModelSelected: (model) async {
          final notifier = ref.read(providerSettingsProvider.notifier);
          await notifier.update(settings.copyWith(model: model.id));
          ref.invalidate(providerSettingsProvider);
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('已切换到 ${model.displayName}')),
            );
          }
        },
      ),
    );
  }
}

class _ModelInfoGrid extends StatelessWidget {
  final AIModel model;

  const _ModelInfoGrid({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        _InfoRow(
          label: '上下文长度',
          value: '${(model.contextLength / 1000).toStringAsFixed(0)}K',
        ),
        const SizedBox(height: 8),
        _InfoRow(
          label: '最大输出',
          value: '${(model.maxTokens / 1000).toStringAsFixed(0)}K',
        ),
        const SizedBox(height: 8),
        _InfoRow(
          label: '输入价格',
          value: model.inputPrice > 0 
              ? '\$${model.inputPrice.toStringAsFixed(4)}/1K tokens'
              : '未知',
        ),
        const SizedBox(height: 8),
        _InfoRow(
          label: '输出价格',
          value: model.outputPrice > 0
              ? '\$${model.outputPrice.toStringAsFixed(4)}/1K tokens'
              : '未知',
        ),
        if (model.capabilities.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: model.capabilities.map((capability) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Tokens.blueDark20 : Tokens.blue10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getCapabilityDisplayName(capability),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  String _getCapabilityDisplayName(String capability) {
    switch (capability) {
      case 'text':
        return '文本';
      case 'vision':
        return '视觉';
      case 'function_calling':
        return '函数调用';
      case 'code_generation':
        return '代码生成';
      default:
        return capability;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ModelsGrid extends StatelessWidget {
  final List<AIModel> models;

  const _ModelsGrid({required this.models});

  @override
  Widget build(BuildContext context) {
    if (models.isEmpty) {
      return const _EmptyModelsCard();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: models.length,
      itemBuilder: (context, index) => _ModelCard(model: models[index]),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final AIModel model;

  const _ModelCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // TODO: 显示模型详情
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isDark ? Tokens.blueDark20 : Tokens.blue10,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.smart_toy_outlined,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? Tokens.greenDark20 : Tokens.green10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      model.providerName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Tokens.greenDark100 : Tokens.green100,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                model.displayName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${(model.contextLength / 1000).toStringAsFixed(0)}K 上下文',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                ),
              ),
              const Spacer(),
              if (model.capabilities.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: model.capabilities.take(2).map((capability) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: isDark ? Tokens.blueDark20 : Tokens.blue10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getCapabilityDisplayName(capability),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 9,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCapabilityDisplayName(String capability) {
    switch (capability) {
      case 'text':
        return '文本';
      case 'vision':
        return '视觉';
      case 'function_calling':
        return '函数';
      default:
        return capability;
    }
  }
}

class _EmptyModelsCard extends StatelessWidget {
  const _EmptyModelsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark ? Tokens.blueDark20 : Tokens.blue10,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.smart_toy_outlined,
                color: theme.colorScheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无可用模型',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请先配置供应商设置，然后刷新模型列表',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomModelsList extends StatelessWidget {
  final List<AIModel> models;
  final Function(AIModel) onEdit;
  final Function(AIModel) onDelete;

  const _CustomModelsList({
    required this.models,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: models.map((model) => _CustomModelTile(
        model: model,
        onEdit: () => onEdit(model),
        onDelete: () => onDelete(model),
      )).toList(),
    );
  }
}

class _CustomModelTile extends StatelessWidget {
  final AIModel model;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomModelTile({
    required this.model,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isDark ? Tokens.blueDark20 : Tokens.blue10,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.smart_toy_outlined,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          model.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          model.provider,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
              tooltip: '编辑',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
              tooltip: '删除',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCustomModelsCard extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyCustomModelsCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 48,
              color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
            ),
            const SizedBox(height: 12),
            Text(
              '暂无自定义模型',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '添加您自己的模型配置',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('添加模型'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              '加载失败',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}