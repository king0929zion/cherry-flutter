import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

import '../../providers/app_state.dart';
import '../../providers/assistant_provider.dart';
import '../../providers/topic_provider.dart';
import '../../services/topic_service.dart';
import '../../models/assistant.dart';
import '../../theme/tokens.dart';
import '../../widgets/welcome_title.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _showImportSheet = false;

  Future<void> _handleStart() async {
    final topicService = ref.read(topicServiceProvider);
    final assistantsAsync = ref.watch(assistantsProvider);
    
    final assistants = assistantsAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <AssistantModel>[],
    );
    
    final defaultAssistant = assistants.firstWhere(
      (a) => a.id == 'default',
      orElse: () => assistants.isNotEmpty ? assistants.first : AssistantModel(
        id: 'default',
        name: '默认助手',
        prompt: '',
        type: 'built_in',
        emoji: '🤖',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    final newTopic = await topicService.createTopic(
      assistantId: defaultAssistant.id,
      name: '新对话',
    );

    await ref.read(welcomeShownProvider.notifier).setShown(true);
    
    if (mounted) {
      context.go('/home/chat/${newTopic.id}');
    }
  }

  Future<void> _handleImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result != null && result.files.single.path != null) {
      // TODO: 实现数据导入逻辑
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据导入功能开发中')),
        );
      }
    }
    setState(() => _showImportSheet = false);
  }

  Future<void> _handleLandrop() async {
    setState(() => _showImportSheet = false);
    // TODO: 导航到 Landrop 设置页面
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Landrop 功能开发中')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight,
      body: SafeArea(
        child: Stack(
          children: [
            // 主要内容区域
            Column(
              children: [
                // 顶部图标和标题区域（占据 3/4 空间）
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 图标（176x176，圆角35）
                        Container(
                          width: 176,
                          height: 176,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(35),
                            child: Image.asset(
                              'assets/images/favicon.png',
                              width: 176,
                              height: 176,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // 如果图片不存在，显示占位符
                                return Container(
                                  width: 176,
                                  height: 176,
                                  decoration: BoxDecoration(
                                    color: isDark ? Tokens.greenDark20 : Tokens.green10,
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '🍒',
                                      style: TextStyle(fontSize: 80),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // 标题和圆点
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const WelcomeTitle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white : Colors.black,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 底部按钮区域（占据 1/4 空间）
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? Tokens.cardDark : Tokens.cardLight,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 导入按钮
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => setState(() => _showImportSheet = true),
                            style: FilledButton.styleFrom(
                              backgroundColor: isDark ? Tokens.greenDark100 : Tokens.green100,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '从 Cherry Studio 导入',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // 开始按钮
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _handleStart,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                              side: BorderSide(
                                color: isDark
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.black.withOpacity(0.15),
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '开始',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // 导入数据底部表单
            if (_showImportSheet) _ImportDataSheet(
              onImport: _handleImport,
              onLandrop: _handleLandrop,
              onDismiss: () => setState(() => _showImportSheet = false),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportDataSheet extends StatelessWidget {
  final VoidCallback onImport;
  final VoidCallback onLandrop;
  final VoidCallback onDismiss;

  const _ImportDataSheet({
    required this.onImport,
    required this.onLandrop,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black54,
        child: GestureDetector(
          onTap: () {}, // 阻止事件冒泡
          child: DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.25,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF121213) : const Color(0xFFF7F7F7),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    // 拖拽指示器
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // 内容
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        children: [
                          _ImportOption(
                            icon: Icons.folder_outlined,
                            title: '从文件恢复',
                            onTap: onImport,
                          ),
                          const SizedBox(height: 12),
                          _ImportOption(
                            icon: Icons.wifi_outlined,
                            title: '通过 Landrop 传输',
                            onTap: onLandrop,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ImportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ImportOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B1F26) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
