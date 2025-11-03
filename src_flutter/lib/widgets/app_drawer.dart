import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/boxes.dart';
import '../theme/tokens.dart';
import 'menu_tab_content.dart';
import 'topic_item.dart';

/// AppDrawer - 应用侧边抽屉
/// 完全复刻原项目的布局与样式
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight;

    return Drawer(
      backgroundColor: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // 间距 gap-2.5 = 10px
            const SizedBox(height: 10),
            
            // 菜单项区域 gap-1.5 px-2.5
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10), // px-2.5
              child: Column(
                children: [
                  // 我的助手
                  _DrawerMenuItem(
                    icon: Icons.assistant_outlined,
                    label: '我的助手',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/assistant');
                    },
                  ),
                  const SizedBox(height: 6), // gap-1.5
                  
                  // MCP 市场
                  _DrawerMenuItem(
                    icon: Icons.extension_outlined,
                    label: 'MCP 市场',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/mcp');
                    },
                  ),
                  
                  // 分割线 - 匹配原项目
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10), // px-2.5
                    child: Divider(
                      height: 1,
                      color: isDark 
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.06),
                    ),
                  ),
                ],
              ),
            ),

            // 最近主题列表
            Expanded(
              child: MenuTabContent(
                title: '最近主题', // TODO: i18n
                onSeeAllPress: () {
                  Navigator.pop(context);
                  context.go('/home/topic');
                },
                child: _RecentTopicsList(),
              ),
            ),

            // 底部分割线 - 匹配原项目 px-5 pb-2.5
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10), // px-5 pb-2.5
              child: Divider(
                height: 1,
                color: isDark 
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06),
              ),
            ),

            // 底部用户信息区域 - 匹配原项目
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0), // px-5
              child: Row(
                children: [
                  // 用户头像和名称 - 匹配原项目 gap-2.5 items-center
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/settings/about/personal');
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: Row(
                          children: [
                            // 头像 - 匹配原项目 w-12 h-12 rounded-full
                            Container(
                              width: 48, // w-12 = 48px
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24), // rounded-full
                                // TODO: 从设置读取头像
                                color: Tokens.brand,
                              ),
                              child: const Center(
                                child: Text(
                                  'C',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10), // gap-2.5
                            // 名称 - 匹配原项目 text-base
                            Text(
                              'Cherry Studio', // TODO: 从设置读取
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 16, // text-base
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // 设置按钮 - 匹配原项目 paddingRight: 16
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      icon: const Icon(Icons.settings_outlined, size: 24),
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/settings');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// DrawerMenuItem - 抽屉菜单项
/// 匹配原项目：flex-row justify-between items-center py-2.5 px-2.5 rounded-lg
class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8), // rounded-lg
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // py-2.5 px-2.5
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // justify-between
            children: [
              Row(
                children: [
                  Icon(icon, size: 24),
                  const SizedBox(width: 10), // gap-2.5
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16, // text-base
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// RecentTopicsList - 最近主题列表
class _RecentTopicsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 获取最近的主题列表
    final topics = Boxes.topics.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList()
      ..sort((a, b) =>
          (b['updatedAt'] as int).compareTo(a['updatedAt'] as int));

    if (topics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            '暂无主题', // TODO: i18n
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: topics.length.clamp(0, 10),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final topic = topics[i];
        final topicId = topic['id'] as String;
        
        // TODO: 获取助手信息
        final assistantName = '默认助手'; // topic['assistantName']
        final assistantEmoji = '🤖'; // topic['assistantEmoji']

        return TopicItem(
          topicId: topicId,
          topicName: topic['name'] as String? ?? '新对话',
          assistantName: assistantName,
          assistantEmoji: assistantEmoji,
          updatedAt: topic['updatedAt'] as int,
          isActive: false, // TODO: 判断是否为当前主题
          onTap: () {
            Navigator.pop(ctx);
            context.go('/home/chat/$topicId');
          },
        );
      },
    );
  }
}
