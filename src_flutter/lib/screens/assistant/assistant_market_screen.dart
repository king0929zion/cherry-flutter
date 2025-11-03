import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/built_in_assistants.dart';
import '../../models/assistant.dart';
import '../../theme/tokens.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/header_bar.dart';
import '../assistant/widgets/assistant_market_card.dart';
import '../assistant/widgets/assistant_market_sheet.dart';

/// Removed local _HeaderBar - using common HeaderBar widget
/*
class _HeaderBar extends StatelessWidget {
  final String title;

  const _HeaderBar({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // 匹配原项目：px-4 items-center h-[44px] justify-between
    return Container(
      height: 44, // h-[44px]
      padding: const EdgeInsets.symmetric(horizontal: 16), // px-4
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // justify-between
        crossAxisAlignment: CrossAxisAlignment.center, // items-center
        children: [
          // Left area - min-w-[40px]
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 24),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          // Title - text-[18px] font-bold text-center
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18, // text-[18px]
                fontWeight: FontWeight.bold, // font-bold
                color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
              ),
            ),
          ),
          // Right area - min-w-[40px]
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
*/

class AssistantMarketScreen extends ConsumerStatefulWidget {
  const AssistantMarketScreen({super.key});

  @override
  ConsumerState<AssistantMarketScreen> createState() => _AssistantMarketScreenState();
}

class _AssistantMarketScreenState extends ConsumerState<AssistantMarketScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';
  String? _selectedGroup; // null 表示全部

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AssistantModel> _filter(List<AssistantModel> assistants) {
    final query = _keyword.trim().toLowerCase();
    return assistants.where((assistant) {
      final matchesText = () {
        if (query.isEmpty) return true;
        final haystack = [
          assistant.name,
          assistant.description,
          assistant.prompt,
          ...(assistant.group ?? const []),
          ...(assistant.tags ?? const []),
        ].join(' ').toLowerCase();
        return haystack.contains(query);
      }();

      final matchesGroup = () {
        if (_selectedGroup == null || _selectedGroup!.isEmpty) return true;
        final groups = assistant.group ?? const [];
        return groups.contains(_selectedGroup);
      }();

      return matchesText && matchesGroup;
    }).toList();
  }

  List<String> _computeGroups(List<AssistantModel> assistants) {
    final set = <String>{};
    for (final a in assistants) {
      for (final g in a.group ?? const <String>[]) {
        if (g.trim().isNotEmpty) set.add(g.trim());
      }
    }
    final list = set.toList()..sort();
    return list;
  }

  Future<void> _openAssistant(BuildContext context, AssistantModel assistant) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => AssistantMarketSheet(assistant: assistant),
    );
  }

  @override
  Widget build(BuildContext context) {
    final builtIns = ref.watch(builtInAssistantsProvider);

    return builtIns.when(
      data: (list) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final groups = _computeGroups(list);
        final filtered = _filter(list);

        return Scaffold(
          backgroundColor: isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                HeaderBar(
                  title: '助手市场',
                  leftButton: HeaderBarButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                    ),
                    onPress: () => context.pop(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        // 搜索输入
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildSearchField(context),
                        ),
                        const SizedBox(height: 10),
                        // 分组筛选（吸顶，因内部仅 GridView 滚动）
                        _GroupChips(
                          groups: groups,
                          selected: _selectedGroup,
                          onSelected: (value) => setState(() => _selectedGroup = value),
                        ),
                        const SizedBox(height: 10),
                        // 网格列表
                        Expanded(
                          child: filtered.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      '未找到匹配的助手',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: 16,
                                        color: Tokens.gray60,
                                      ),
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: GridView.builder(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).padding.bottom + 32,
                                    ),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 6,
                                      mainAxisSpacing: 6,
                                      childAspectRatio: 0.78,
                                    ),
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      final assistant = filtered[index];
                                      return AssistantMarketCard(
                                        assistant: assistant,
                                        onTap: () => _openAssistant(context, assistant),
                                      );
                                    },
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
      },
      loading: () => Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Tokens.bgPrimaryDark
            : Tokens.bgPrimaryLight,
        body: const Center(child: LoadingIndicator(message: '正在加载助手市场...')),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Tokens.bgPrimaryDark
            : Tokens.bgPrimaryLight,
        body: ErrorView(
          message: '助手市场加载失败',
          details: err.toString(),
          onRetry: () => ref.invalidate(builtInAssistantsProvider),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Tokens.cardDark : Tokens.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _keyword = value),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 16,
          color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
          ),
          suffixIcon: _keyword.isEmpty
              ? null
              : IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _keyword = '');
                  },
                ),
          hintText: '搜索助手...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}

class _GroupChips extends StatelessWidget {
  final List<String> groups;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _GroupChips({
    required this.groups,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final items = ['全部', ...groups];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final label = items[i];
          final isAll = label == '全部';
          final isSelected = isAll ? selected == null : selected == label;
          final bg = isSelected
              ? (isDark ? Tokens.greenDark20 : Tokens.green10)
              : Colors.transparent;
          final fg = isSelected
              ? (isDark ? Tokens.greenDark100 : Tokens.green100)
              : (isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight);
          final border = isSelected
              ? (isDark ? Tokens.greenDark20 : Tokens.green20)
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08));

          return GestureDetector(
            onTap: () => onSelected(isAll ? null : label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: border, width: 0.8),
              ),
              child: Row(
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: items.length,
      ),
    );
  }
}
