import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/assistant.dart';
import '../../models/model.dart';
import '../../providers/assistant_provider.dart';
import '../../providers/mcp_settings.dart' show mcpSettingsProvider, McpSettingsNotifier, McpServer;
import '../../providers/provider_settings.dart';
import '../../services/model_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/emoji_avatar.dart';
import '../../widgets/header_bar.dart';

/// AssistantDetailScreen - Flutter 复刻原项目的助手详情编辑界面
/// 包含提示词、模型、工具三个标签页，支持 Emoji 头像编辑、模型参数配置、工具开关等功能
class AssistantDetailScreen extends ConsumerStatefulWidget {
  final String assistantId;

  const AssistantDetailScreen({super.key, required this.assistantId});

  @override
  ConsumerState<AssistantDetailScreen> createState() => _AssistantDetailScreenState();
}

class _AssistantDetailScreenState extends ConsumerState<AssistantDetailScreen>
    with SingleTickerProviderStateMixin {
  static const _tabTitles = ['提示词', '模型', '工具'];

  late final TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();
  final TextEditingController _maxTokensController = TextEditingController();

  AssistantModel? _assistant;
  Map<String, dynamic> _settings = {};
  List<String> _selectedMcpServerIds = [];
  String _selectedEmoji = '🤖';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    ref.listen<AsyncValue<List<AssistantModel>>>(
      assistantNotifierProvider,
      (previous, next) {
        next.whenData((value) {
          final assistant = _findAssistant(value);
          if (assistant != null) {
            _scheduleSync(assistant);
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    _nameController.dispose();
    _promptController.dispose();
    _descriptionController.dispose();
    _temperatureController.dispose();
    _contextController.dispose();
    _maxTokensController.dispose();
    super.dispose();
  }

  AssistantModel? _findAssistant(List<AssistantModel> list) {
    for (final item in list) {
      if (item.id == widget.assistantId) return item;
    }
    return null;
  }

  void _scheduleSync(AssistantModel assistant) {
    if (!mounted) return;
    if (_assistant != null && _assistant!.updatedAt == assistant.updatedAt) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncAssistant(assistant);
    });
  }

  void _syncAssistant(AssistantModel assistant) {
    _assistant = assistant;
    _selectedEmoji = assistant.emoji ?? '🤖';
    _settings = _parseSettings(assistant);
    _selectedMcpServerIds = _parseMcpServers(assistant);

    _nameController
      ..text = assistant.name
      ..selection = TextSelection.fromPosition(TextPosition(offset: assistant.name.length));
    _promptController.text = assistant.prompt;
    _descriptionController.text = assistant.description ?? '';
    _temperatureController.text = _formatNumber(_settings['temperature'] ?? 0.7);
    _contextController.text = (_settings['contextCount'] ?? 8192).toString();
    _maxTokensController.text = (_settings['maxTokens'] ?? 2048).toString();
    setState(() {});
  }

  Map<String, dynamic> _parseSettings(AssistantModel assistant) {
    if (assistant.settings == null || assistant.settings!.isEmpty) {
      return <String, dynamic>{
        'temperature': 0.7,
        'contextCount': 8192,
        'maxTokens': 2048,
      };
    }
    try {
      final decoded = jsonDecode(assistant.settings!);
      if (decoded is Map<String, dynamic>) {
        return {
          'temperature': (decoded['temperature'] as num?)?.toDouble() ?? 0.7,
          'contextCount': (decoded['contextCount'] as num?)?.toInt() ?? 8192,
          'maxTokens': (decoded['maxTokens'] as num?)?.toInt() ?? 2048,
          'reasoning_effort': decoded['reasoning_effort'] ?? 'off',
        };
      }
    } catch (_) {
      // ignore parse error and fallback to defaults
    }
    return <String, dynamic>{
      'temperature': 0.7,
      'contextCount': 8192,
      'maxTokens': 2048,
    };
  }

  List<String> _parseMcpServers(AssistantModel assistant) {
    if (assistant.mcpServers == null || assistant.mcpServers!.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(assistant.mcpServers!);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {
      // fallback to comma separated
      return assistant.mcpServers!
          .split(',')
          .map((e) => e.trim())
          .where((element) => element.isNotEmpty)
          .toList();
    }
    return [];
  }

  String _formatNumber(dynamic value) {
    if (value is num) {
      return value.toString();
    }
    return value?.toString() ?? '';
  }

  void _scheduleDebounce(VoidCallback action) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), action);
  }

  Future<void> _updateAssistant({
    String? name,
    String? prompt,
    String? emoji,
    String? description,
    bool? enableWebSearch,
    bool? enableGenerateImage,
    String? defaultModelId,
    Map<String, dynamic>? settingsOverride,
    List<String>? mcpServerIds,
  }) async {
    if (_assistant == null) return;

    final notifier = ref.read(assistantNotifierProvider.notifier);
    final settingsJson = settingsOverride != null ? jsonEncode(settingsOverride) : null;
    final mcpServersJson = mcpServerIds != null ? jsonEncode(mcpServerIds) : null;

    try {
      await notifier.updateAssistant(
        _assistant!.id,
        name: name,
        prompt: prompt,
        emoji: emoji,
        description: description,
        defaultModel: defaultModelId,
        model: defaultModelId,
        settings: settingsJson,
        enableWebSearch: enableWebSearch,
        enableGenerateImage: enableGenerateImage,
        mcpServers: mcpServersJson,
      );

      final updated = _assistant!.copyWith(
        name: name ?? _assistant!.name,
        prompt: prompt ?? _assistant!.prompt,
        emoji: emoji ?? _assistant!.emoji,
        description: description ?? _assistant!.description,
        defaultModel: defaultModelId ?? _assistant!.defaultModel,
        model: defaultModelId ?? _assistant!.model,
        settings: settingsJson ?? _assistant!.settings,
        enableWebSearch: enableWebSearch ?? _assistant!.enableWebSearch,
        enableGenerateImage: enableGenerateImage ?? _assistant!.enableGenerateImage,
        mcpServers: mcpServersJson ?? _assistant!.mcpServers,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      _assistant = updated;
      if (settingsOverride != null) {
        _settings = settingsOverride;
      }
      if (mcpServerIds != null) {
        _selectedMcpServerIds = mcpServerIds;
      }
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('更新助手失败: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final assistantsAsync = ref.watch(assistantNotifierProvider);
    return assistantsAsync.when(
      loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('加载助手失败: $error'),
          ),
        ),
      ),
      data: (assistants) {
        final assistant = _findAssistant(assistants);
        if (assistant == null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.smart_toy_outlined, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      '未找到助手',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '当前助手可能已被删除或尚未创建。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => context.pop(),
                      child: const Text('返回'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        _scheduleSync(assistant);

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final mcpServers = ref.watch(mcpSettingsProvider);

        final isNew = assistant.createdAt == assistant.updatedAt && assistant.name.isEmpty;
        final title = isNew ? '创建助手' : '编辑助手';

        return Scaffold(
          backgroundColor: isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                HeaderBar(
                  title: title,
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
                  child: Column(
                    children: [
                      _buildAvatarSection(context),
                      const SizedBox(height: 16),
                      _buildTabBar(theme, isDark),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildPromptTab(theme, isDark),
                            _buildModelTab(theme, isDark),
                            _buildToolTab(theme, isDark, mcpServers),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              EmojiAvatar(
                emoji: _selectedEmoji,
                size: 106,
                borderRadius: 28,
                borderWidth: 5,
                borderColor: isDark ? const Color(0xFF2E3136) : const Color(0xFFF2F5F0),
                backgroundColor: isDark ? const Color(0xFF1E2127) : const Color(0xFFF4F4F7),
              ),
              Material(
                color: isDark ? Tokens.greenDark100 : Tokens.green100,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _showEmojiPicker(context),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '点击编辑助手头像',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2229) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
          ),
        ),
        child: TabBar(
          controller: _tabController,
          labelPadding: EdgeInsets.zero,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark ? Tokens.greenDark20 : Tokens.green10,
          ),
          labelColor: isDark ? Tokens.greenDark100 : Tokens.green100,
          unselectedLabelColor: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
          tabs: _tabTitles
              .map(
                (title) => SizedBox(
                  height: 48,
                  child: Center(
                    child: Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildPromptTab(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            theme: theme,
            isDark: isDark,
            title: '基础信息',
            children: [
              _buildLabel(theme, isDark, '名称'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.done,
                decoration: _inputDecoration(theme, isDark, hintText: '请输入助手名称'),
                onChanged: (_) => _scheduleDebounce(() {
                  _updateAssistant(name: _nameController.text.trim());
                }),
              ),
              const SizedBox(height: 20),
              _buildLabel(theme, isDark, '描述 (可选)'),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: _inputDecoration(theme, isDark, hintText: '展示在助手列表中的简介'),
                minLines: 1,
                maxLines: 3,
                onSubmitted: (value) {
                  _updateAssistant(description: value.trim().isEmpty ? null : value.trim());
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            theme: theme,
            isDark: isDark,
            title: '系统提示词',
            children: [
              _buildLabel(theme, isDark, '设定助手的角色与语气'),
              const SizedBox(height: 8),
              TextField(
                controller: _promptController,
                decoration: _inputDecoration(
                  theme,
                  isDark,
                  hintText: '例如：你是一个友好的 AI 助手...'
                ),
                minLines: 6,
                maxLines: 18,
                onChanged: (_) => _scheduleDebounce(() {
                  _updateAssistant(prompt: _promptController.text.trim());
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModelTab(ThemeData theme, bool isDark) {
    final providerSettings = ref.watch(providerSettingsProvider);
    final modelService = ref.read(modelServiceProvider);
    final selectedModelId = _assistant?.defaultModel;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            theme: theme,
            isDark: isDark,
            title: '默认模型',
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final models = await modelService.getAvailableModels(providerSettings);
                  if (!mounted) return;
                  final selected = await _showModelPicker(context, models, selectedModelId);
                  if (selected != null) {
                    _updateAssistant(defaultModelId: selected.id);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F232A) : const Color(0xFFF6F7F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                children: [
                      Icon(
                        Icons.memory_rounded,
                        size: 20,
                        color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                              selectedModelId ?? '未选择',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '点击选择默认模型',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            theme: theme,
            isDark: isDark,
            title: '模型参数',
            children: [
              _buildLabel(theme, isDark, '温度'),
              const SizedBox(height: 8),
              TextField(
                controller: _temperatureController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration(theme, isDark, hintText: '0.0 ~ 1.5'),
                onSubmitted: (value) {
                  final parsed = double.tryParse(value);
                  final settings = Map<String, dynamic>.from(_settings);
                  settings['temperature'] = parsed == null ? 0.7 : parsed.clamp(0, 2.0);
                  _updateAssistant(settingsOverride: settings);
                },
              ),
              const SizedBox(height: 16),
              _buildLabel(theme, isDark, '上下文长度'),
              const SizedBox(height: 8),
              TextField(
                controller: _contextController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(theme, isDark, hintText: '默认为 8192'),
                onSubmitted: (value) {
                  final parsed = int.tryParse(value);
                  final settings = Map<String, dynamic>.from(_settings);
                  settings['contextCount'] = parsed == null ? 8192 : parsed.clamp(1024, 200000);
                  _updateAssistant(settingsOverride: settings);
                },
              ),
              const SizedBox(height: 16),
              _buildLabel(theme, isDark, '最大 Tokens'),
                        const SizedBox(height: 8),
                        TextField(
                controller: _maxTokensController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(theme, isDark, hintText: '默认为 2048'),
                onSubmitted: (value) {
                  final parsed = int.tryParse(value);
                  final settings = Map<String, dynamic>.from(_settings);
                  settings['maxTokens'] = parsed == null ? 2048 : parsed.clamp(256, 32768);
                  _updateAssistant(settingsOverride: settings);
                },
              ),
              const SizedBox(height: 16),
              _buildReasoningButton(theme, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReasoningButton(ThemeData theme, bool isDark) {
    final effort = (_settings['reasoning_effort'] as String?) ?? 'off';
    return ElevatedButton.icon(
      onPressed: () async {
        final selected = await _showReasoningSheet(context, effort);
        if (selected != null) {
          final settings = Map<String, dynamic>.from(_settings);
          settings['reasoning_effort'] = selected;
          _updateAssistant(settingsOverride: settings);
        }
      },
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
          ),
        ),
      ),
      icon: Icon(
        Icons.auto_awesome,
        color: isDark ? Tokens.greenDark100 : Tokens.green100,
      ),
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('推理模式'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Tokens.greenDark20 : Tokens.green10,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? Tokens.greenDark100 : Tokens.green100,
                width: 0.5,
              ),
            ),
            child: Text(
              _reasoningLabel(effort),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Tokens.greenDark100 : Tokens.green100,
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  String _reasoningLabel(String effort) {
    switch (effort) {
      case 'low':
        return '低强度';
      case 'medium':
        return '中等';
      case 'high':
        return '高强度';
      default:
        return '关闭';
    }
  }

  Widget _buildToolTab(ThemeData theme, bool isDark, List<McpServer> servers) {
    final enableWebSearch = _assistant?.enableWebSearch ?? false;
    final enableImage = _assistant?.enableGenerateImage ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            theme: theme,
            isDark: isDark,
            title: '工具与能力',
            children: [
              SwitchListTile.adaptive(
                value: enableWebSearch,
                onChanged: (value) => _updateAssistant(enableWebSearch: value),
                title: const Text('启用联网搜索'),
                subtitle: Text(
                  '允许助手在回答时访问 Web 搜索结果',
                  style: theme.textTheme.bodySmall,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile.adaptive(
                value: enableImage,
                onChanged: (value) => _updateAssistant(enableGenerateImage: value),
                title: const Text('启用图片生成'),
                subtitle: Text(
                  '使用图像模型生成插画或照片',
                  style: theme.textTheme.bodySmall,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              _buildLabel(theme, isDark, '关联 MCP 服务器'),
              const SizedBox(height: 8),
              _buildMcpServerSelector(theme, isDark, servers),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMcpServerSelector(ThemeData theme, bool isDark, List<McpServer> servers) {
    final selected = servers
        .where((element) => _selectedMcpServerIds.contains(element.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
                children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selected.isEmpty
              ? [
                  Text(
                    '尚未绑定任何 MCP 服务器',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                    ),
                  ),
                ]
              : selected
                  .map(
                    (server) => Chip(
                      label: Text(server.name),
                      backgroundColor: isDark ? Tokens.greenDark10 : Tokens.green10,
                      labelStyle: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Tokens.greenDark100 : Tokens.green100,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: isDark ? Tokens.greenDark20 : Tokens.green20,
                        width: 0.6,
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            final selected = await _showMcpServerSelector(context, servers, _selectedMcpServerIds);
            if (selected != null) {
              _updateAssistant(mcpServerIds: selected);
            }
          },
          icon: const Icon(Icons.link_outlined, size: 18),
          label: Text(
            _selectedMcpServerIds.isEmpty ? '绑定服务器' : '编辑绑定',
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required bool isDark,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181B20) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(ThemeData theme, bool isDark, String text) {
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : const Color(0xFF14161A),
      ),
    );
  }

  InputDecoration _inputDecoration(ThemeData theme, bool isDark, {String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: isDark ? const Color(0xFF1D2026) : const Color(0xFFF7F8FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.8),
      ),
    );
  }

  Future<AIModel?> _showModelPicker(
    BuildContext context,
    List<AIModel> models,
    String? selectedId,
  ) async {
    return showModalBottomSheet<AIModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF171A1F) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('选择模型', style: theme.textTheme.titleMedium),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      itemCount: models.length,
                      separatorBuilder: (_, __) => Divider(
                        color: isDark ? Colors.white12 : Colors.black12,
                        height: 1,
                      ),
                      itemBuilder: (_, index) {
                        final model = models[index];
                        final isSelected = model.id == selectedId;
                        return ListTile(
                          title: Text(model.name),
                          subtitle: model.description != null
                              ? Text(
                                  model.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                              : null,
                          onTap: () => Navigator.pop(ctx, model),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _showReasoningSheet(BuildContext context, String current) async {
    const options = [
      'off',
      'low',
      'medium',
      'high',
    ];

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF171A1F) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('推理强度', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              for (final option in options)
                ListTile(
                  title: Text(_reasoningLabel(option)),
                  trailing: option == current
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  onTap: () => Navigator.pop(ctx, option),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<List<String>?> _showMcpServerSelector(
    BuildContext context,
    List<McpServer> servers,
    List<String> selectedIds,
  ) async {
    final selected = selectedIds.toSet();
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.72,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF181B20) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black26,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('绑定 MCP 服务器', style: theme.textTheme.titleMedium),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: servers.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final server = servers[index];
                          final isSelected = selected.contains(server.id);
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (value) {
                              setModalState(() {
                                if (value == true) {
                                  selected.add(server.id);
                                } else {
                                  selected.remove(server.id);
                                }
                              });
                            },
                            title: Text(server.name),
                            subtitle: server.description != null && server.description!.isNotEmpty
                                ? Text(server.description!)
                                : Text(server.endpoint),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx, selectedIds),
                              child: const Text('取消'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => Navigator.pop(ctx, selected.toList()),
                              child: const Text('确认'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showEmojiPicker(BuildContext context) async {
    const emojis = [
      '🤖', '👨‍💻', '👩‍💻', '🧑‍🎓', '👨‍🏫', '👩‍🏫',
      '🧙', '🧚', '👨‍⚕️', '👩‍⚕️', '👨‍🔬', '👩‍🔬',
      '🎨', '🎭', '🎪', '🎬', '🎤', '🎧',
      '💡', '🔮', '🌟', '⭐', '✨', '🎯',
      '🚀', '🛸', '🌈', '☀️', '🌙', '⚡',
    ];

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF171A1F) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('选择 Emoji', style: theme.textTheme.titleMedium),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                itemCount: emojis.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (_, index) {
                  final emoji = emojis[index];
                  final isSelected = emoji == _selectedEmoji;
                  return GestureDetector(
                    onTap: () => Navigator.pop(ctx, emoji),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? Tokens.greenDark20 : Tokens.green10)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? Tokens.greenDark100 : Tokens.green100)
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && selected != _selectedEmoji) {
      _selectedEmoji = selected;
      _updateAssistant(emoji: selected);
    }
  }
}
