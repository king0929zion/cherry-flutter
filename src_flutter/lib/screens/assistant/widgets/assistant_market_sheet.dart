import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../services/assistant_service.dart';
import '../../../services/topic_service.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/settings_group.dart';

class AssistantMarketSheet extends ConsumerStatefulWidget {
  final Assistant assistant;

  const AssistantMarketSheet({super.key, required this.assistant});

  @override
  ConsumerState<AssistantMarketSheet> createState() => _AssistantMarketSheetState();
}

class _AssistantMarketSheetState extends ConsumerState<AssistantMarketSheet> {
  bool _isProcessing = false;

  Future<void> _handleAddToMyAssistants(BuildContext context) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final svc = ref.read(assistantServiceProvider);
      await svc.importBuiltInAssistant(widget.assistant);
      ref.invalidate(assistantsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已添加 ${widget.assistant.name} 到我的助手')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleStartChat(BuildContext context) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final svc = ref.read(assistantServiceProvider);
      final topicSvc = ref.read(topicServiceProvider);
      final newAssistant = await svc.importBuiltInAssistant(widget.assistant);
      ref.invalidate(assistantsProvider);
      final topic = await topicSvc.createTopic(
        assistantId: newAssistant.id,
        name: widget.assistant.name,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      context.go('/home/chat/${topic.id}');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('开始聊天失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                color: Colors.black.withOpacity(isDark ? 0.6 : 0.25),
                offset: const Offset(0, -12),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Container(
                height: 4,
                width: 42,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white.withOpacity(isDark ? 0.08 : 0.2),
                              border: Border.all(
                                color: Colors.white.withOpacity(isDark ? 0.2 : 0.3),
                                width: 3,
                              ),
                            ),
                            child: Text(
                              widget.assistant.emoji ?? '🤖',
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.assistant.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.category_outlined, size: 18),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        widget.assistant.group?.join(' · ') ??
                                            '未分组',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: isDark
                                              ? Tokens.textSecondaryDark
                                              : Tokens.textSecondaryLight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      SettingsGroup(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '助手简介',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.assistant.description ??
                                      '该助手暂未提供简介。',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.5,
                                    color: isDark
                                        ? Tokens.textSecondaryDark
                                        : Tokens.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if ((widget.assistant.tags?.isNotEmpty ?? false) ||
                          (widget.assistant.group?.isNotEmpty ?? false))
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (widget.assistant.group != null)
                                ...widget.assistant.group!.map(
                                  (g) => _InfoTag(label: g),
                                ),
                              if (widget.assistant.tags != null)
                                ...widget.assistant.tags!.map(
                                  (t) => _InfoTag(
                                    label: t,
                                    color: isDark
                                        ? Tokens.blueDark20
                                        : Tokens.blue20,
                                    foreground: isDark
                                        ? Tokens.textPrimaryDark
                                        : Tokens.textPrimaryLight,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      if ((widget.assistant.prompt?.isNotEmpty ?? false))
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: SettingsGroup(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '系统提示词',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      widget.assistant.prompt ?? '',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        height: 1.55,
                                        color: isDark
                                            ? Tokens.textSecondaryDark
                                            : Tokens.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 26),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton.icon(
                            onPressed: _isProcessing
                                ? null
                                : () => _handleAddToMyAssistants(context),
                            icon: _isProcessing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.library_add_outlined, size: 18),
                            label: const Text('添加到我的助手'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _isProcessing
                                ? null
                                : () => _handleStartChat(context),
                            icon: const Icon(Icons.forum_outlined, size: 18),
                            label: const Text('立即与该助手对话'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoTag extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? foreground;

  const _InfoTag({
    required this.label,
    this.color,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color ??
            (isDark ? Tokens.bgSecondaryDark.withOpacity(0.3) : Tokens.bgSecondaryLight),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: foreground ??
              (isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight),
        ),
      ),
    );
  }
}
