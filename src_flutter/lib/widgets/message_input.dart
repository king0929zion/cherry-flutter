import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../models/attachment.dart';
import '../theme/tokens.dart';

String _guessMime(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.gif')) return 'image/gif';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.txt')) return 'text/plain';
  if (lower.endsWith('.pdf')) return 'application/pdf';
  return 'application/octet-stream';
}

/// MessageInput - 消息输入框组件
/// 完全复刻原项目的布局:
/// - 外层带阴影的圆角容器
/// - 文件预览区域
/// - 文本输入框(多行,透明背景)
/// - 底部工具栏:
///   - 左侧: 工具按钮组(附件、思考、提及、MCP)
///   - 右侧: 发送/暂停按钮(动画切换)
class MessageInput extends StatefulWidget {
  final Future<void> Function(String text, List<PickedAttachment> attachments) onSubmit;
  final bool isSending;

  const MessageInput({
    super.key,
    required this.onSubmit,
    this.isSending = false,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  final List<PickedAttachment> _attachments = [];
  bool _localSending = false;

  bool get _isSending => widget.isSending || _localSending;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if ((text.isEmpty && _attachments.isEmpty) || _isSending) return;
    
    setState(() => _localSending = true);
    try {
      await widget.onSubmit(text, List.unmodifiable(_attachments));
      _controller.clear();
      _attachments.clear();
    } finally {
      if (mounted) setState(() => _localSending = false);
    }
  }

  Future<void> _pickFiles() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (res == null) return;
    
    for (final f in res.files) {
      if (f.bytes == null) continue;
      _attachments.add(PickedAttachment(
        name: f.name,
        mime: _guessMime(f.name),
        bytes: f.bytes!,
      ));
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: bottomPadding > 0 ? bottomPadding : 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 文件预览区域
          if (_attachments.isNotEmpty) ...[
            _buildFilePreview(),
            const SizedBox(height: 10),
          ],
          
          // 文本输入框
          Container(
            constraints: const BoxConstraints(
              minHeight: 96, // h-24
              maxHeight: 200,
            ),
            child: TextField(
              controller: _controller,
              maxLines: null,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: '输入消息...', // TODO: i18n
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          
          const SizedBox(height: 10), // gap-[10px]
          
          // 按钮区域
          Row(
            children: [
              // 左侧工具按钮组
              Expanded(
                child: Row(
                  children: [
                    // 附件按钮
                    _ToolIconButton(
                      icon: Icons.attach_file,
                      onPressed: _isSending ? null : _pickFiles,
                      tooltip: '附件',
                    ),
                    const SizedBox(width: 10),
                    
                    // TODO: 思考按钮 (ThinkButton)
                    // TODO: 提及按钮 (MentionButton)
                    // TODO: MCP按钮 (McpButton)
                  ],
                ),
              ),
              
              // 右侧发送/暂停按钮
              const SizedBox(width: 20), // gap-5
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: _isSending
                    ? _PauseButton(
                        key: const ValueKey('pause'),
                        onPressed: () {
                          // TODO: 实现暂停功能
                        },
                      )
                    : _SendButton(
                        key: const ValueKey('send'),
                        onPressed: _controller.text.trim().isEmpty ? null : _send,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview() {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _attachments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final a = _attachments[i];
          return _FilePreviewItem(
            fileName: a.name,
            onRemove: () => setState(() => _attachments.removeAt(i)),
          );
        },
      ),
    );
  }
}

/// 工具图标按钮
class _ToolIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  const _ToolIconButton({
    required this.icon,
    this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 24),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
      ),
    );
  }
}

/// 发送按钮
class _SendButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _SendButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.send,
        size: 24,
        color: onPressed == null ? Tokens.gray40 : Tokens.brand,
      ),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
    );
  }
}

/// 暂停按钮
class _PauseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PauseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.stop_circle, size: 24, color: Tokens.red100),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
    );
  }
}

/// 文件预览项
class _FilePreviewItem extends StatelessWidget {
  final String fileName;
  final VoidCallback onRemove;

  const _FilePreviewItem({
    required this.fileName,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file, size: 20, color: theme.iconTheme.color),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              fileName,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRemove,
            child: Icon(Icons.close, size: 16, color: theme.iconTheme.color),
          ),
        ],
      ),
    );
  }
}
