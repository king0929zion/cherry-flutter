import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/mcp_settings.dart' show mcpSettingsProvider, McpSettingsNotifier, McpServer;
import '../../services/mcp_service.dart';
import '../../theme/tokens.dart';

class McpScreen extends ConsumerWidget {
  const McpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final servers = ref.watch(mcpSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP 服务器'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_outlined),
            onPressed: () => context.go('/mcp/editor'),
            tooltip: '添加服务器',
          ),
        ],
      ),
      body: _buildContent(context, ref, servers, theme, isDark),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<McpServer> servers,
    ThemeData theme,
    bool isDark,
  ) {
    if (servers.isEmpty) {
      return _buildEmptyState(context, theme, isDark);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(mcpSettingsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: servers.length,
        itemBuilder: (context, index) {
          final server = servers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _McpServerCard(
              server: server,
              onTap: () => context.go('/mcp/editor/${server.id}'),
              onToggle: () => _toggleServerStatus(ref, server),
              onDelete: () => _showDeleteDialog(context, ref, server),
              onTest: () => _testConnection(context, ref, server),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark ? Tokens.blueDark20 : Tokens.blue10,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.cloud_outlined,
                size: 40,
                color: isDark ? Tokens.blueDark100 : Tokens.blue100,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无 MCP 服务器',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '添加 MCP 服务器以扩展 AI 助手的功能',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/mcp/editor'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('添加服务器'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, ThemeData theme, bool isDark, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ref.refresh(mcpSettingsProvider);
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleServerStatus(WidgetRef ref, McpServer server) async {
    await ref.read(mcpSettingsProvider.notifier).toggleActive(server.id);
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref, McpServer server) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除服务器'),
        content: Text('确定要删除服务器 "${server.name}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(mcpSettingsProvider.notifier).remove(server.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('服务器已删除')),
        );
      }
    }
  }

  Future<void> _testConnection(BuildContext context, WidgetRef ref, McpServer server) async {
    final service = ref.read(mcpServiceProvider);
    final isConnected = await service.testMcpServerConnection(server);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isConnected ? '连接成功' : '连接失败'),
          backgroundColor: isConnected ? Colors.green : Colors.red,
        ),
      );
    }
  }
}

class _McpServerCard extends StatelessWidget {
  final McpServer server;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTest;

  const _McpServerCard({
    required this.server,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
    required this.onTest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final description = server.description ?? '';
    final hasDescription = description.isNotEmpty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
        ),
      ),
      color: isDark ? Tokens.cardDark : Tokens.cardLight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧：服务器信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            server.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (hasDescription) ...[
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // 右侧：开关和类型标签
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Switch.adaptive(
                    value: server.isActive,
                    onChanged: (_) => onToggle(),
                    activeColor: isDark ? Tokens.greenDark100 : Tokens.green100,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? Tokens.greenDark10 : Tokens.green10,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Tokens.greenDark20 : Tokens.green20,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      _formatServerType(server.type),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Tokens.greenDark100 : Tokens.green100,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatServerType(McpServerType type) {
    switch (type) {
      case McpServerType.streamableHttp:
        return 'HTTP';
      case McpServerType.sse:
        return 'SSE';
    }
  }
}
