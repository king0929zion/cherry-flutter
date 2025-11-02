import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/mcp.dart';
import '../../services/mcp_service.dart';
import '../../theme/tokens.dart';
import '../../utils/ids.dart';

class McpServerEditorScreen extends ConsumerStatefulWidget {
  final String? serverId;

  const McpServerEditorScreen({
    super.key,
    this.serverId,
  });

  @override
  ConsumerState<McpServerEditorScreen> createState() => _McpServerEditorScreenState();
}

class _McpServerEditorScreenState extends ConsumerState<McpServerEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _headersController = TextEditingController();
  final _timeoutController = TextEditingController();
  
  McpServerType _serverType = McpServerType.streamableHttp;
  bool _isActive = true;
  bool _isLoading = false;
  McpServer? _originalServer;

  @override
  void initState() {
    super.initState();
    _loadServer();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _baseUrlController.dispose();
    _headersController.dispose();
    _timeoutController.dispose();
    super.dispose();
  }

  Future<void> _loadServer() async {
    if (widget.serverId != null) {
      final service = ref.read(mcpServiceProvider);
      final server = await service.getMcpServer(widget.serverId!);
      if (server != null) {
        setState(() {
          _originalServer = server;
          _nameController.text = server.name;
          _descriptionController.text = server.description ?? '';
          _baseUrlController.text = server.baseUrl;
          _serverType = server.type;
          _headersController.text = _formatHeaders(server.headers);
          _timeoutController.text = server.timeout?.toString() ?? '';
          _isActive = server.isActive;
        });
      }
    }
  }

  String _formatHeaders(Map<String, String>? headers) {
    if (headers == null || headers.isEmpty) return '';
    try {
      return const JsonEncoder.withIndent('  ').convert(headers);
    } catch (e) {
      return '';
    }
  }

  Map<String, String>? _parseHeaders(String headersText) {
    if (headersText.trim().isEmpty) return null;
    
    try {
      final parsed = jsonDecode(headersText);
      if (parsed is Map) {
        return Map<String, String>.from(parsed);
      }
    } catch (e) {
      throw Exception('请求头格式无效，请输入有效的 JSON 格式');
    }
    
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(mcpServiceProvider);
      final headers = _parseHeaders(_headersController.text);
      final timeout = _timeoutController.text.isNotEmpty
          ? int.tryParse(_timeoutController.text)
          : null;

      if (timeout != null && timeout <= 0) {
        throw Exception('超时时间必须大于 0');
      }

      // 验证 URL 格式
      try {
        Uri.parse(_baseUrlController.text.trim());
      } catch (e) {
        throw Exception('基础 URL 格式无效');
      }

      final serverData = McpServer(
        id: widget.serverId ?? newId(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        baseUrl: _baseUrlController.text.trim(),
        type: _serverType,
        headers: headers,
        timeout: timeout,
        isActive: _isActive,
        disabledTools: _originalServer?.disabledTools ?? [],
      );

      if (widget.serverId != null) {
        await service.updateMcpServer(widget.serverId!, serverData);
      } else {
        await service.createMcpServer(serverData);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.serverId != null ? '服务器已更新' : '服务器已创建'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.serverId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑服务器' : '添加服务器'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSection(
              title: '基本信息',
              children: [
                _TextFormField(
                  controller: _nameController,
                  label: '服务器名称',
                  hintText: '例如: 我的 MCP 服务器',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入服务器名称';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _TextFormField(
                  controller: _descriptionController,
                  label: '描述',
                  hintText: '服务器功能描述（可选）',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _TextFormField(
                  controller: _baseUrlController,
                  label: '基础 URL',
                  hintText: 'https://your-server.example.com/mcp',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入基础 URL';
                    }
                    try {
                      Uri.parse(value.trim());
                    } catch (e) {
                      return '请输入有效的 URL';
                    }
                    return null;
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '连接配置',
              children: [
                Text(
                  '服务器类型',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ServerTypeOption(
                        type: McpServerType.streamableHttp,
                        title: 'HTTP',
                        description: '标准 HTTP 连接',
                        isSelected: _serverType == McpServerType.streamableHttp,
                        onTap: () => setState(() => _serverType = McpServerType.streamableHttp),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ServerTypeOption(
                        type: McpServerType.sse,
                        title: 'SSE',
                        description: 'Server-Sent Events',
                        isSelected: _serverType == McpServerType.sse,
                        onTap: () => setState(() => _serverType = McpServerType.sse),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _TextFormField(
                  controller: _headersController,
                  label: '请求头',
                  hintText: '{ "Authorization": "Bearer ..." }',
                  maxLines: 5,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      try {
                        _parseHeaders(value);
                      } catch (e) {
                        return e.toString();
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _TextFormField(
                  controller: _timeoutController,
                  label: '超时时间（秒）',
                  hintText: '30',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final timeout = int.tryParse(value);
                      if (timeout == null || timeout <= 0) {
                        return '请输入有效的超时时间';
                      }
                    }
                    return null;
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '状态',
              children: [
                SwitchListTile(
                  title: Text(
                    '启用服务器',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    _isActive ? '服务器已启用' : '服务器已禁用',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                    ),
                  ),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Tokens.cardDark : Tokens.cardLight,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ServerTypeOption extends StatelessWidget {
  final McpServerType type;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServerTypeOption({
    required this.type,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? isDark ? Tokens.greenDark : Tokens.green
                : isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
          ),
          color: isSelected
              ? isDark ? Tokens.greenDark20 : Tokens.green10
              : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? isDark ? Tokens.greenDark : Tokens.green
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final int? maxLines;
  final TextInputType? keyboardType;

  const _TextFormField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.validator,
    this.maxLines,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1,
              ),
            ),
            filled: true,
            fillColor: isDark ? Tokens.surfaceDark : Tokens.surfaceLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}