import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/model_provider.dart';
import '../providers/provider_settings.dart';
import '../models/model.dart';
import '../theme/tokens.dart';
import '../utils/icons.dart';

class ModelSelector extends ConsumerStatefulWidget {
  final Function(AIModel) onModelSelected;
  final AIModel? initialModel;
  final bool allowMultiple;

  const ModelSelector({
    super.key,
    required this.onModelSelected,
    this.initialModel,
    this.allowMultiple = false,
  });

  @override
  ConsumerState<ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends ConsumerState<ModelSelector> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  Set<String> _selectedModelIds = {};
  bool _isMultiSelectMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialModel != null) {
      _selectedModelIds.add(widget.initialModel!.id);
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _onModelTap(AIModel model) {
    if (widget.allowMultiple && _isMultiSelectMode) {
      setState(() {
        if (_selectedModelIds.contains(model.id)) {
          _selectedModelIds.remove(model.id);
        } else {
          _selectedModelIds.add(model.id);
        }
      });
    } else {
      // 单选模式，直接选择并关闭
      widget.onModelSelected(model);
      Navigator.pop(context);
    }
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode && _selectedModelIds.length > 1) {
        // 切换到单选模式时，只保留第一个选中的模型
        _selectedModelIds = {_selectedModelIds.first};
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedModelIds.clear();
    });
  }

  void _confirmSelection() {
    final selectedModels = ref.read(filteredModelsProvider)
        .where((model) => _selectedModelIds.contains(model.id))
        .toList();
    
    if (selectedModels.isNotEmpty) {
      widget.onModelSelected(selectedModels.first);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final modelsAsync = ref.watch(filteredModelsProvider);
    final providerSettings = ref.watch(providerSettingsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121213) : const Color(0xFFF7F7F7),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFFF9F9F9) : const Color(0xFF202020),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 搜索栏和多选控制
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '搜索模型...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDark 
                              ? Tokens.cardDark.withOpacity(0.5) 
                              : Tokens.cardLight.withOpacity(0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (widget.allowMultiple) ...[
                      GestureDetector(
                        onTap: _toggleMultiSelectMode,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isMultiSelectMode
                                ? isDark ? Tokens.greenDark20 : Tokens.green10
                                : isDark ? Tokens.cardDark : Tokens.cardLight,
                            borderRadius: BorderRadius.circular(20),
                            border: _isMultiSelectMode
                                ? Border.all(color: isDark ? Tokens.greenDark : Tokens.green)
                                : null,
                          ),
                          child: Text(
                            '多选',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _isMultiSelectMode
                                  ? isDark ? Tokens.greenDark : Tokens.green
                                  : isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_isMultiSelectMode)
                        GestureDetector(
                          onTap: _clearSelection,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? Tokens.cardDark : Tokens.cardLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.clear,
                              size: 18,
                              color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
                if (_isMultiSelectMode && _selectedModelIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Text(
                          '已选择 ${_selectedModelIds.length} 个模型',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _confirmSelection,
                          child: const Text('确认'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // 模型列表
          Expanded(
            child: modelsAsync.isEmpty
                ? _EmptyModelView(isDark: isDark)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: modelsAsync.length,
                    itemBuilder: (context, index) {
                      final model = modelsAsync[index];
                      final isSelected = _selectedModelIds.contains(model.id);
                      
                      return _ModelTile(
                        model: model,
                        isSelected: isSelected,
                        onTap: () => _onModelTap(model),
                        isDark: isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ModelTile extends StatelessWidget {
  final AIModel model;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ModelTile({
    required this.model,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? isDark ? Tokens.greenDark : Tokens.green
                    : Colors.transparent,
                width: 1,
              ),
              color: isSelected
                  ? isDark ? Tokens.greenDark20 : Tokens.green10
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                // 模型图标
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isDark ? Tokens.blueDark20 : Tokens.blue10,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    getModelOrProviderIcon(model.id, model.provider, isDark),
                    size: 16,
                    color: isDark ? Tokens.blueDark : Tokens.blue,
                  ),
                ),
                const SizedBox(width: 12),
                
                // 模型名称
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? isDark ? Tokens.greenDark : Tokens.green
                              : isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        model.providerName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 模型标签
                Row(
                  children: [
                    if (model.contextLength >= 100000)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? Tokens.blueDark20 : Tokens.blue10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '长上下文',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Tokens.blueDark : Tokens.blue,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    if (model.capabilities.contains('vision')) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? Tokens.purpleDark20 : Tokens.purple10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '视觉',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Tokens.purpleDark : Tokens.purple,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                    
                    // 选中指示器
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: isDark ? Tokens.greenDark : Tokens.green,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyModelView extends StatelessWidget {
  final bool isDark;

  const _EmptyModelView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark ? Tokens.blueDark20 : Tokens.blue10,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.smart_toy_outlined,
                size: 40,
                color: isDark ? Tokens.blueDark : Tokens.blue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无可用模型',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请检查供应商配置或添加自定义模型',
              style: theme.textTheme.bodyMedium?.copyWith(
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