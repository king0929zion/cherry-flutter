import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/assistant_service.dart';
import '../../widgets/emoji_avatar.dart';
import '../../widgets/settings_group.dart';

/// AssistantDetailScreen - 助手详情页面
/// 编辑助手信息：名称、Emoji、系统提示词
class AssistantDetailScreen extends ConsumerStatefulWidget {
  final String assistantId;
  const AssistantDetailScreen({super.key, required this.assistantId});

  @override
  ConsumerState<AssistantDetailScreen> createState() => _AssistantDetailScreenState();
}

class _AssistantDetailScreenState extends ConsumerState<AssistantDetailScreen> {
  final _nameController = TextEditingController();
  final _promptController = TextEditingController();
  String _selectedEmoji = '🤖';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _saveAssistant(Assistant assistant) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名称不能为空')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final list = await ref.read(assistantServiceProvider).getAssistants();
      final idx = list.indexWhere((e) => e.id == assistant.id);
      if (idx >= 0) {
        list[idx] = assistant.copyWith(
          name: _nameController.text.trim(),
          emoji: _selectedEmoji,
          prompt: _promptController.text.trim().isEmpty 
              ? null 
              : _promptController.text.trim(),
        );
        await ref.read(assistantServiceProvider).saveAssistants(list);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('保存成功')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref.read(assistantServiceProvider).getAssistant(widget.assistantId),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final assistant = snap.data as Assistant?;
        if (assistant == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('助手详情')),
            body: const Center(child: Text('未找到助手')),
          );
        }

        // 初始化控制器
        if (_nameController.text.isEmpty) {
          _nameController.text = assistant.name;
          _promptController.text = assistant.prompt ?? '';
          _selectedEmoji = assistant.emoji ?? '🤖';
        }

        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('助手详情'), // TODO: i18n
            centerTitle: false,
            actions: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                TextButton(
                  onPressed: () => _saveAssistant(assistant),
                  child: const Text('保存'),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Emoji 头像
              Center(
                child: GestureDetector(
                  onTap: () => _showEmojiPicker(context),
                  child: EmojiAvatar(
                    emoji: _selectedEmoji,
                    size: 100,
                    borderRadius: 24,
                    borderWidth: 4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () => _showEmojiPicker(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('更换头像'),
                ),
              ),

              const SizedBox(height: 32),

              // 基本信息
              const SettingsSectionTitle(title: '基本信息'),
              const SizedBox(height: 8),
              SettingsGroup(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '名称',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: '输入助手名称',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 系统提示词
              const SettingsSectionTitle(title: '系统提示词'),
              const SizedBox(height: 8),
              SettingsGroup(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '定义助手的行为和回复风格',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _promptController,
                          decoration: InputDecoration(
                            hintText: '例如：你是一个友好的助手...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          minLines: 5,
                          maxLines: 15,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  void _showEmojiPicker(BuildContext context) {
    final emojis = [
      '🤖', '👨‍💻', '👩‍💻', '🧑‍🎓', '👨‍🏫', '👩‍🏫',
      '🧙', '🧚', '👨‍⚕️', '👩‍⚕️', '👨‍🔬', '👩‍🔬',
      '🎨', '🎭', '🎪', '🎬', '🎤', '🎧',
      '💡', '🔮', '🌟', '⭐', '✨', '🎯',
      '🚀', '🛸', '🌈', '☀️', '🌙', '⚡',
    ];

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择 Emoji',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: emojis.length,
                itemBuilder: (ctx, i) {
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedEmoji = emojis[i]);
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedEmoji == emojis[i]
                            ? Theme.of(ctx).colorScheme.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          emojis[i],
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
