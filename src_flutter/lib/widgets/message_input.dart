import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/attachment.dart';
import '../theme/tokens.dart';
import '../ui/cherry_icons.dart';

class MessageInput extends StatefulWidget {
  final Future<void> Function(String text, List<PickedAttachment> attachments) onSubmit;
  final bool isSending;
  final VoidCallback? onPause;

  const MessageInput({
    super.key,
    required this.onSubmit,
    this.isSending = false,
    this.onPause,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<PickedAttachment> _attachments = [];
  bool _localSending = false;

  bool get _isSending => widget.isSending || _localSending;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;

    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null) continue;
      _attachments.add(
        PickedAttachment(
          name: file.name,
          mime: _guessMime(file.name),
          bytes: bytes,
        ),
      );
    }
    if (mounted) setState(() {});
  }

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

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('该功能暂未实现，敬请期待'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final containerPadding = max(bottomInset, 12.0);
    final canSend = _controller.text.trim().isNotEmpty || _attachments.isNotEmpty;

    final containerColor = isDark ? const Color(0xFF181B1F) : Colors.white;
    final outlineColor =
        isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.06);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, containerPadding),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: outlineColor),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.32)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: _attachments.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              _attachments.length,
                              (index) => Padding(
                                padding: EdgeInsets.only(
                                  right: index == _attachments.length - 1 ? 0 : 10,
                                ),
                                child: _AttachmentChip(
                                  attachment: _attachments[index],
                                  onRemove: () => _removeAttachment(index),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 68,
                  maxHeight: 200,
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  onChanged: (_) => setState(() {}),
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  decoration: InputDecoration(
                    hintText: '输入内容…',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  textInputAction: TextInputAction.newline,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _ToolButton(
                          icon: CherryIcons.assets(
                            size: 18,
                            color: isDark
                                ? Tokens.textPrimaryDark
                                : Tokens.textPrimaryLight,
                          ),
                          onTap: _pickFiles,
                          semanticLabel: '添加附件',
                        ),
                        _ToolButton(
                          icon: CherryIcons.lightbulbOff(
                            size: 18,
                            color: isDark ? Tokens.greenDark100 : Tokens.green100,
                          ),
                          onTap: _showComingSoon,
                          semanticLabel: '思考模式',
                        ),
                        _MentionPill(onTap: _showComingSoon),
                        _ToolButton(
                          icon: CherryIcons.mcp(
                            size: 18,
                            color: isDark
                                ? Tokens.textPrimaryDark
                                : Tokens.textPrimaryLight,
                          ),
                          onTap: _showComingSoon,
                          semanticLabel: 'MCP',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: _isSending
                        ? _PauseButton(
                            key: const ValueKey('pause'),
                            onPressed: widget.onPause ?? () {},
                          )
                        : _SendButton(
                            key: const ValueKey('send'),
                            enabled: canSend,
                            onPressed: canSend ? _send : null,
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
}

class _ToolButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final String semanticLabel;

  const _ToolButton({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark ? const Color(0xFF1F242A) : const Color(0xFFF4F5F6),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
            ),
          ),
          alignment: Alignment.center,
          child: icon,
        ),
      ),
    );
  }
}

class _MentionPill extends StatelessWidget {
  final VoidCallback onTap;

  const _MentionPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: isDark ? Tokens.greenDark10 : Tokens.green10,
          border: Border.all(
            color: isDark ? Tokens.greenDark20 : Tokens.green20,
            width: 0.7,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.alternate_email,
              size: 16,
              color: isDark ? Tokens.greenDark100 : Tokens.green100,
            ),
            const SizedBox(width: 6),
            Text(
              '模型',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Tokens.greenDark100 : Tokens.green100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool enabled;

  const _SendButton({
    super.key,
    required this.onPressed,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: enabled
              ? const LinearGradient(
                  colors: [Color(0xFFC0E58D), Color(0xFF3BB554)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: enabled ? null : const Color(0xFF2A2F38),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF3BB554).withOpacity(0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: enabled
            ? CherryIcons.arrowUp(size: 22)
            : Icon(
                Icons.arrow_upward,
                size: 20,
                color: Colors.white.withOpacity(0.4),
              ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PauseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: const Color(0xFFED6767),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.pause_circle_filled,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  final PickedAttachment attachment;
  final VoidCallback onRemove;

  const _AttachmentChip({
    required this.attachment,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? const Color(0xFF1F242A) : const Color(0xFFF4F5F6),
        border: Border.all(
          color:
              isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CherryIcons.assets(
            size: 18,
            color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              attachment.name,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: theme.iconTheme.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

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
