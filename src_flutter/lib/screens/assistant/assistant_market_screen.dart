import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/built_in_assistants.dart';
import '../../services/assistant_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../assistant/widgets/assistant_market_card.dart';
import '../assistant/widgets/assistant_market_sheet.dart';

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

  List<Assistant> _filter(List<Assistant> assistants) {
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

  Future<void> _openAssistant(BuildContext context, Assistant assistant) async {
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
        final filtered = _filter(list);
        return Scaffold(
          appBar: AppBar(
            title: const Text('助手市场'),
            centerTitle: false,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildSearchField(context),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: filtered.isEmpty
                      ? EmptyState(
                          icon: Icons.shelves,
                          title: '未找到匹配的助手',
                          description: '试试更换关键词或查看其他分类',
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.builder(
                            padding: const EdgeInsets.only(bottom: 32),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
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
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: LoadingIndicator(message: '正在加载助手市场...')),
      ),
      error: (err, stack) => Scaffold(
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? Tokens.borderDark : Tokens.borderLight).withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _keyword = value),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _keyword.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _keyword = '');
                  },
                ),
          hintText: '搜索助手、标签或分类',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
      ),
    );
  }
}
