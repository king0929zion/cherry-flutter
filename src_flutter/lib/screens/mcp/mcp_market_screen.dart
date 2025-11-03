import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/mcp.dart';
import '../../services/mcp_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/header_bar.dart';
import 'mcp_server_editor_screen.dart';

class McpMarketScreen extends ConsumerWidget {
  const McpMarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HeaderBar(
              title: 'MCP 市场',
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
              child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '发现 MCP 服务器',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '浏览和发现可用的 MCP 服务器，扩展您的 AI 助手功能',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            
            // 推荐服务器
            _RecommendedServers(),
            
            const SizedBox(height: 32),
            
            // 服务器分类
            _ServerCategories(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedServers extends ConsumerWidget {
  const _RecommendedServers();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '推荐服务器',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _RecommendedServerCard(
              name: '文件系统',
              description: '访问和管理本地文件系统',
              icon: Icons.folder_outlined,
              color: Colors.blue,
              onTap: () => _installServer(context, ref, 'filesystem'),
            ),
            _RecommendedServerCard(
              name: 'Web 浏览',
              description: '浏览和获取网页内容',
              icon: Icons.language_outlined,
              color: Colors.green,
              onTap: () => _installServer(context, ref, 'web-browser'),
            ),
            _RecommendedServerCard(
              name: '数据库',
              description: '连接和查询各种数据库',
              icon: Icons.storage_outlined,
              color: Colors.purple,
              onTap: () => _installServer(context, ref, 'database'),
            ),
            _RecommendedServerCard(
              name: 'Git',
              description: '管理 Git 仓库和版本控制',
              icon: Icons.code_outlined,
              color: Colors.orange,
              onTap: () => _installServer(context, ref, 'git'),
            ),
          ],
        ),
      ],
    );
  }

  void _installServer(BuildContext context, WidgetRef ref, String serverType) {
    // TODO: 实现服务器安装逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('安装 $serverType 服务器功能正在开发中')),
    );
  }
}

class _RecommendedServerCard extends StatelessWidget {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RecommendedServerCard({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: color.withOpacity(0.1),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(36),
                  backgroundColor: color.withOpacity(0.1),
                  foregroundColor: color,
                ),
                child: const Text('安装'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServerCategories extends ConsumerWidget {
  const _ServerCategories();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final categories = [
      _ServerCategory(
        name: '开发工具',
        description: '代码编辑、调试、版本控制等',
        icon: Icons.code_outlined,
        servers: 12,
      ),
      _ServerCategory(
        name: '数据处理',
        description: '数据库、文件处理、数据分析等',
        icon: Icons.data_object_outlined,
        servers: 8,
      ),
      _ServerCategory(
        name: '网络服务',
        description: 'API 调用、网页抓取、网络监控等',
        icon: Icons.cloud_outlined,
        servers: 15,
      ),
      _ServerCategory(
        name: '系统管理',
        description: '系统监控、进程管理、日志分析等',
        icon: Icons.settings_outlined,
        servers: 6,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '服务器分类',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...categories.map((category) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ServerCategoryCard(category: category),
        )),
      ],
    );
  }
}

class _ServerCategory {
  final String name;
  final String description;
  final IconData icon;
  final int servers;

  const _ServerCategory({
    required this.name,
    required this.description,
    required this.icon,
    required this.servers,
  });
}

class _ServerCategoryCard extends StatelessWidget {
  final _ServerCategory category;

  const _ServerCategoryCard({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // TODO: 导航到分类详情页面
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isDark ? Tokens.blueDark20 : Tokens.blue10,
                ),
                alignment: Alignment.center,
                child: Icon(
                  category.icon,
                  size: 28,
                  color: isDark ? Tokens.blueDark100 : Tokens.blue100,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${category.servers}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    '服务器',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
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