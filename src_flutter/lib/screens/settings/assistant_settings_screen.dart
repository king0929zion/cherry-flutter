import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/assistant_assignments.dart';
import '../../providers/assistant_provider.dart';
import '../../models/assistant.dart';
import '../../theme/tokens.dart';

class AssistantSettingsScreen extends ConsumerWidget {
  const AssistantSettingsScreen({super.key});

  static const _roles = [
    _AssistantRoleConfig(
      role: 'default',
      title: '默认助手',
      description: '主聊天默认使用的助手',
      fallbackEmoji: '🤖',
      icon: Icons.chat_bubble_outline,
      gradientLight: [Color(0xFFE5F2FF), Color(0xFFFFFFFF)],
      gradientDark: [Color(0xFF212532), Color(0xFF161922)],
    ),
    _AssistantRoleConfig(
      role: 'quick',
      title: '快速助手',
      description: '提供简洁回答，适合速问速答',
      fallbackEmoji: '⚡',
      icon: Icons.bolt_outlined,
      gradientLight: [Color(0xFFFFF4E5), Color(0xFFFFFFFF)],
      gradientDark: [Color(0xFF2A2118), Color(0xFF18120B)],
    ),
    _AssistantRoleConfig(
      role: 'translate',
      title: '翻译助手',
      description: '专注中英文互译与润色',
      fallbackEmoji: '🌐',
      icon: Icons.translate,
      gradientLight: [Color(0xFFEAFBF2), Color(0xFFFFFFFF)],
      gradientDark: [Color(0xFF1E2A22), Color(0xFF141B16)],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assistantsAsync = ref.watch(assistantsProvider);
    final assignmentsAsync = ref.watch(assistantAssignmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('助手设置'),
        centerTitle: false,
      ),
      body: assistantsAsync.when(
        data: (assistants) {
          if (assistants.isEmpty) {
            return _EmptyAssistants(onCreate: () async {
              await ref.read(assistantServiceProvider).createAssistant(name: '新助手', prompt: '');
              ref.invalidate(assistantsProvider);
            });
          }
          return assignmentsAsync.when(
            data: (assignments) => _buildContent(
              context,
              ref,
              assistants,
              assignments ?? const {},
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (err, _) => _ErrorState(
              message: '加载角色绑定失败',
              onRetry: () => ref.invalidate(assistantAssignmentsProvider),
              details: err.toString(),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorState(
          message: '加载助手列表失败',
          onRetry: () => ref.invalidate(assistantsProvider),
          details: err.toString(),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<AssistantModel> assistants,
    Map<String, String?> assignments,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final assistantMap = {for (final a in assistants) a.id: a};

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '角色绑定',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 12),
        ..._roles.map((config) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _AssistantRoleTile(
              config: config,
              assistants: assistants,
              currentId: assignments[config.role],
              onSelect: (id) async {
                await ref.read(assistantServiceProvider).assign(config.role, id);
                ref.invalidate(assistantAssignmentsProvider);
                final selected = assistantMap[id];
                if (selected != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${config.title} 已绑定到 ${selected.name}')),
                  );
                }
              },
              onManage: (id) => context.go('/assistant/$id'),
            ),
          );
        }),
        const SizedBox(height: 8),
        Text(
          '提示：可在“我的助手”中新建/编辑自定义助手，并绑定为上述角色以快速切换体验。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '管理',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Tokens.blue10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.manage_accounts_outlined, size: 20),
            ),
            title: const Text('打开我的助手'),
            subtitle: const Text('创建、编辑或删除自定义助手'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/assistant'),
          ),
        ),
      ],
    );
  }
}

class _AssistantRoleTile extends StatelessWidget {
  final _AssistantRoleConfig config;
  final List<AssistantModel> assistants;
  final String? currentId;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onManage;

  const _AssistantRoleTile({
    required this.config,
    required this.assistants,
    required this.currentId,
    required this.onSelect,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selected = _findCurrent();
    final colors = isDark ? config.gradientDark : config.gradientLight;
    final surfaceColor = isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.45 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showPicker(context, selected?.id),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: surfaceColor.withOpacity(isDark ? 0.16 : 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(config.icon, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          config.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          config.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? Tokens.textSecondaryDark
                                : Tokens.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed:
                        selected != null ? () => onManage(selected.id) : null,
                    child: const Text('管理'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor.withOpacity(isDark ? 0.12 : 0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.white.withOpacity(isDark ? 0.08 : 0.2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        (selected?.emoji ?? config.fallbackEmoji),
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selected?.name ?? '未绑定',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selected?.description ??
                                '点击选择一个助手进行绑定',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? Tokens.textSecondaryDark
                                  : Tokens.textSecondaryLight,
                              height: 1.35,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if ((selected?.tags?.isNotEmpty ?? false) ||
                              (selected?.group?.isNotEmpty ?? false))
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  if (selected?.group != null)
                                    ...selected!.group!.take(2).map(
                                          (g) => _TagChip(
                                            label: g,
                                            background: isDark
                                                ? Tokens.blueDark20
                                                : Tokens.blue10,
                                            foreground: isDark
                                                ? Tokens.textPrimaryDark
                                                : Tokens.textPrimaryLight,
                                          ),
                                        ),
                                  if (selected?.tags != null)
                                    ...selected!.tags!.take(2).map(
                                          (t) => _TagChip(
                                            label: t,
                                            background: isDark
                                                ? Tokens.greenDark10
                                                : Tokens.green10,
                                            foreground: isDark
                                                ? Tokens.greenDark100
                                                : Tokens.green100,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AssistantModel? _findCurrent() {
    if (currentId == null) return null;
    for (final assistant in assistants) {
      if (assistant.id == currentId) return assistant;
    }
    return null;
  }

  Future<void> _showPicker(BuildContext context, String? selectedId) async {
    final id = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(config.icon, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '选择${config.title}',
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: assistants.length,
                itemBuilder: (ctx, index) {
                  final assistant = assistants[index];
                  final isSelected = assistant.id == selectedId;
                  return ListTile(
                    leading: Text(
                      assistant.emoji ?? config.fallbackEmoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                    title: Text(assistant.name),
                    subtitle: assistant.description != null
                        ? Text(
                            assistant.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Tokens.brand)
                        : null,
                    onTap: () => Navigator.pop(ctx, assistant.id),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                onManage(selectedId ?? assistants.first.id);
              },
              child: const Text('管理所有助手'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (id != null) {
      onSelect(id);
    }
  }
}

class _AssistantRoleConfig {
  final String role;
  final String title;
  final String description;
  final String fallbackEmoji;
  final IconData icon;
  final List<Color> gradientLight;
  final List<Color> gradientDark;

  const _AssistantRoleConfig({
    required this.role,
    required this.title,
    required this.description,
    required this.fallbackEmoji,
    required this.icon,
    required this.gradientLight,
    required this.gradientDark,
  });
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _TagChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: foreground,
        ),
      ),
    );
  }
}

class _EmptyAssistants extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyAssistants({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy_outlined,
                size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              '暂无助手',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '创建你的第一个助手后即可在此绑定角色，获取更贴近原项目的体验。',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onCreate,
              child: const Text('立即创建助手'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final String details;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.details,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.orange),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              details,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
