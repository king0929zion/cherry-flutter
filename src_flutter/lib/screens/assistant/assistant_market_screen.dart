import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/built_in_assistants.dart';
import '../../models/assistant.dart';
import '../../theme/tokens.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../assistant/widgets/assistant_market_card.dart';
import '../assistant/widgets/assistant_market_sheet.dart';

/// HeaderBar - 匹配原项目的HeaderBar组件
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

class AssistantMarketScreen extends ConsumerStatefulWidget {
  const AssistantMarketScreen({super.key});

  @override
  ConsumerState<AssistantMarketScreen> createState() => _AssistantMarketScreenState();
}

class _AssistantMarketScreenState extends ConsumerState<AssistantMarketScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AssistantModel> _filter(List<AssistantModel> assistants) {
    final query = _keyword.trim().toLowerCase();
    if (query.isEmpty) return assistants;
    return assistants.where((assistant) {
      final haystack = [
        assistant.name,
        assistant.description,
        assistant.prompt,
        ...(assistant.group ?? const []),
        ...(assistant.tags ?? const []),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
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

    // 匹配原项目：SafeAreaContainer Container py-0 gap-2.5
    return builtIns.when(
      data: (list) {
        final filtered = _filter(list);
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Scaffold(
          backgroundColor: isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight,
          body: SafeArea(
            child: Column(
              children: [
                // HeaderBar - 匹配原项目
                _HeaderBar(title: '助手市场'),
                // Container - 匹配原项目：py-0 gap-2.5
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.zero, // py-0
                    child: Column(
                      children: [
                        // SearchInput - 匹配原项目：px-4
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16), // px-4
                          child: _buildSearchField(context),
                        ),
                        const SizedBox(height: 10), // gap-2.5
                        // AssistantsTabContent - 匹配原项目
                        Expanded(
                          child: filtered.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20), // p-5
                                    child: Text(
                                      '未找到匹配的助手',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: 16, // text-base
                                        color: Tokens.gray60,
                                      ),
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6), // p-1.5 = 6px
                                  child: GridView.builder(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).padding.bottom + 32,
                                    ),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 6, // gap-1.5 = 6px
                                      mainAxisSpacing: 6,
                                      childAspectRatio: 0.78, // h-[230px] / width
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

    // 匹配原项目：SearchInput样式
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Tokens.cardDark : Tokens.cardLight, // bg-ui-card-background
        borderRadius: BorderRadius.circular(12), // rounded-xl
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _keyword = value),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 16, // text-base
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), // py-[14px]
        ),
      ),
    );
  }
}
