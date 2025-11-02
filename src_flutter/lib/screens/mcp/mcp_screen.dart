import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/mcp.dart';
import '../../services/mcp_service.dart';
import '../../theme/tokens.dart';
import '../../utils/ids.dart';
import 'mcp_market_screen.dart';
import 'mcp_server_editor_screen.dart';

class McpScreen extends ConsumerWidget {
  const McpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final serversAsync = ref.watch(mcpServersProvider);

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
      body: serversAsync.when(
        data: (servers) => _buildContent(context, ref, servers, theme, isDark),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, theme, isDark, error.toString()),
      ),
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
      onRefresh: () => ref.refresh(mcpServersProvider.future),
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
                color: isDark ? Tokens.blueDark : Tokens.blue,
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

  Widget _buildError(BuildContext context, ThemeData theme, bool isDark, String error) {
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
              onPressed: () => ref.refresh(mcpServersProvider.future),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleServerStatus(WidgetRef ref, McpServer server) async {
    final service = ref.read(mcpServiceProvider);
    await service.updateMcpServer(server.id, server.copyWith(isActive: !server.isActive));
    ref.refresh(mcpServersProvider.future);
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
      final service = ref.read(mcpServiceProvider);
      await service.deleteMcpServer(server.id);
      ref.refresh(mcpServersProvider.future);
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
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: server.isActive
                          ? isDark ? Tokens.greenDark20 : Tokens.green10
                          : isDark ? Tokens.greyDark20 : Tokens.grey10,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      server.isActive ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                      size: 24,
                      color: server.isActive
                          ? isDark ? Tokens.greenDark : Tokens.green
                          : isDark ? Tokens.greyDark : Tokens.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          server.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          server.description ?? '无描述',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: server.isActive,
                    onChanged: (_) => onToggle(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isDark ? Tokens.surfaceDark : Tokens.surfaceLight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server.baseUrl,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? Tokens.blueDark20 : Tokens.blue10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getServerTypeDisplayName(server.type),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Tokens.blueDark : Tokens.blue,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        if (server.timeout != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '超时: ${server.timeout}s',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onTest,
                    icon: const Icon(Icons.wifi_tethering_outlined, size: 18),
                    label: const Text('测试连接'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    tooltip: '删除',
                    style: IconButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
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

  String _getServerTypeDisplayName(McpServerType type) {
    switch (type) {
      case McpServerType.streamableHttp:
        return 'HTTP';
      case McpServerType.sse:
        return 'SSE';
    }
  }
}

final mcpServersProvider = FutureProvider<List<McpServer>>((ref) async {
  return ref.read(mcpServiceProvider).getMcpServers();
});
