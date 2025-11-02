import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tool_call.dart';
import '../theme/tokens.dart';
import '../utils/expandable_controller.dart';

class ToolCallBlock extends ConsumerStatefulWidget {
  final ToolCallBlock block;

  const ToolCallBlock({
    super.key,
    required this.block,
  });

  @override
  ConsumerState<ToolCallBlock> createState() => _ToolCallBlockState();
}

class _ToolCallBlockState extends ConsumerState<ToolCallBlock>
    with SingleTickerProviderStateMixin {
  late final ExpandableController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = ExpandableController();
    _controller.addListener(_onExpansionChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onExpansionChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onExpansionChanged() {
    if (_controller.isExpanded != _isExpanded) {
      setState(() {
        _isExpanded = _controller.isExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final toolCall = widget.block.toolCall;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
        ),
        color: isDark ? Tokens.cardDark : Tokens.cardLight,
      ),
      child: Column(
        children: [
          // 工具调用头部
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _controller.toggle,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // 状态图标
                    _buildStatusIcon(toolCall, theme, isDark),
                    const SizedBox(width: 12),
                    
                    // 工具名称
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getToolDisplayName(toolCall.name),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getStatusText(toolCall.status),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 展开/收起图标
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more,
                        size: 20,
                        color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 展开内容
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _isExpanded
                ? _buildExpandedContent(toolCall, theme, isDark)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(ToolCall toolCall, ThemeData theme, bool isDark) {
    IconData icon;
    Color color;

    switch (toolCall.status) {
      case ToolCallStatus.pending:
        icon = Icons.hourglass_empty;
        color = isDark ? Tokens.yellowDark : Tokens.yellow;
        break;
      case ToolCallStatus.inProgress:
        icon = Icons.refresh;
        color = isDark ? Tokens.blueDark : Tokens.blue;
        break;
      case ToolCallStatus.done:
        icon = Icons.check_circle;
        color = isDark ? Tokens.greenDark : Tokens.green;
        break;
      case ToolCallStatus.error:
        icon = Icons.error;
        color = isDark ? Tokens.redDark : Tokens.red;
        break;
    }

    if (toolCall.status == ToolCallStatus.inProgress) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    return Icon(
      icon,
      size: 20,
      color: color,
    );
  }

  Widget _buildExpandedContent(ToolCall toolCall, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 参数部分
          if (toolCall.arguments.isNotEmpty) ...[
            Text(
              '参数',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? Tokens.surfaceDark : Tokens.surfaceLight,
              ),
              child: Text(
                _formatJson(toolCall.arguments),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // 响应部分
          if (toolCall.response != null || toolCall.error != null) ...[
            Text(
              toolCall.error != null ? '错误信息' : '响应结果',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: toolCall.error != null
                    ? isDark ? Tokens.redDark20 : Tokens.red10
                    : isDark ? Tokens.surfaceDark : Tokens.surfaceLight,
              ),
              child: Text(
                toolCall.error ?? _formatJson(toolCall.response),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: toolCall.error != null
                      ? isDark ? Tokens.redDark : Tokens.red
                      : null,
                ),
              ),
            ),
          ],
          
          // 时间信息
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '创建时间: ${_formatTime(toolCall.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                ),
              ),
              if (toolCall.completedAt != null) ...[
                const SizedBox(width: 16),
                Text(
                  '完成时间: ${_formatTime(toolCall.completedAt!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getToolDisplayName(String name) {
    if (name.startsWith('builtin_')) {
      return name.replaceFirst('builtin_', '');
    }
    return name;
  }

  String _getStatusText(ToolCallStatus status) {
    switch (status) {
      case ToolCallStatus.pending:
        return '等待中';
      case ToolCallStatus.inProgress:
        return '执行中';
      case ToolCallStatus.done:
        return '已完成';
      case ToolCallStatus.error:
        return '执行失败';
    }
  }

  String _formatJson(dynamic json) {
    try {
      return const JsonEncoder.withIndent('  ').convert(json);
    } catch (e) {
      return json.toString();
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }
}

class ToolCallList extends StatelessWidget {
  final List<ToolCallBlock> toolCalls;

  const ToolCallList({
    super.key,
    required this.toolCalls,
  });

  @override
  Widget build(BuildContext context) {
    if (toolCalls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        ...toolCalls.map((toolCall) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ToolCallBlock(block: toolCall),
        )),
      ],
    );
  }
}