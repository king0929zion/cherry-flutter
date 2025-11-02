import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/attachment.dart';
import '../models/models.dart';
import '../services/assistant_service.dart';
import '../services/topic_service.dart';
import '../theme/tokens.dart';
import '../ui/cherry_icons.dart';

class MessageInput extends StatefulWidget {
  final TopicModel topic;
  final AssistantModel assistant;
  final List<AssistantModel> assistants;
  final Future<void> Function(
    String text,
    List<PickedAttachment> attachments,
    List<String> mentions,
  ) onSubmit;
  final bool isSending;
  final VoidCallback? onPause;

  const MessageInput({
    super.key,
    required this.topic,
    required this.assistant,
    required this.assistants,
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
  late List<String> _selectedMentions;
  bool _localSending = false;

  bool get _isSending => widget.isSending || _localSending;

  @override
  void initState() {
    super.initState();
    _selectedMentions = [widget.assistant.id];
  }

  @override
  void didUpdateWidget(covariant MessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assistant.id != widget.assistant.id) {
      _selectedMentions = [widget.assistant.id];
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  AssistantModel? _findAssistant(String id) {
    try {
      return widget.assistants.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
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
      await widget.onSubmit(
        text,
        List.unmodifiable(_attachments),
        List.unmodifiable(_selectedMentions),
      );
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
          content: Text('该功能尚未实现，敬请期待'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  Future<void> _selectMentions() async {
    final current = Set<String>.from(_selectedMentions);
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _MentionSelector(
          assistants: widget.assistants,
          initialSelection: current,
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _selectedMentions = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final platform = Theme.of(context).platform;
    final extraBottom = platform == TargetPlatform.android ? 8.0 : 0.0;
    final paddingBottom = max(bottomInset + extraBottom, 12.0);
    final canSend = _controller.text.trim().isNotEmpty || _attachments.isNotEmpty;

    final containerColor = isDark ? const Color(0xFF171A1F) : Colors.white;
    final outlineColor =
        isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    final selectedAssistants =
        _selectedMentions.map(_findAssistant).whereType<AssistantModel>().toList();
    final actionItems = <Widget>[];
    void addAction(Widget widget) {
      if (actionItems.isNotEmpty) {
        actionItems.add(const SizedBox(width: 10));
      }
      actionItems.add(widget);
    }

    addAction(
      _ToolButton(
        icon: CherryIcons.assets(
          size: 20,
          color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
        ),
        onTap: _pickFiles,
        semanticLabel: '添加附件',
      ),
    );
    addAction(
      _ToolButton(
        icon: CherryIcons.lightbulbOff(
          size: 20,
          color: isDark ? Tokens.greenDark100 : Tokens.green100,
        ),
        onTap: _showComingSoon,
        semanticLabel: '智能模式',
      ),
    );
    addAction(
      _MentionPill(
        onTap: _selectMentions,
        assistants: selectedAssistants,
      ),
    );
    addAction(
      _ToolButton(
        icon: CherryIcons.mcp(
          size: 20,
          color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
        ),
        onTap: _showComingSoon,
        semanticLabel: 'MCP',
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, paddingBottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: outlineColor),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.32)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              _attachments.length,
                              (index) => Padding(
                                padding: EdgeInsets.only(
                                  right: index == _attachments.length - 1 ? 0 : 8,
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
                  minHeight: 56,
                  maxHeight: 160,
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  onChanged: (_) => setState(() {}),
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                  decoration: InputDecoration(
                    hintText: '发送消息...',
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actionItems,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark ? const Color(0xFF20252C) : const Color(0xFFF3F5F7),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.04),
              ),
            ),
            alignment: Alignment.center,
            child: icon,
          ),
        ),
      ),
    );
  }
}

class _MentionPill extends StatelessWidget {
  final VoidCallback onTap;
  final List<AssistantModel> assistants;

  const _MentionPill({
    required this.onTap,
    required this.assistants,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Tokens.greenDark100 : Tokens.green100;
    final background = isDark ? Tokens.greenDark10 : Tokens.green10;
    final borderColor = isDark ? Tokens.greenDark20 : Tokens.green20;

    final visible = assistants.take(3).toList();
    final children = <Widget>[];

    if (assistants.isEmpty) {
      children.add(Icon(Icons.alternate_email, size: 18, color: textColor));
    } else {
      for (var i = 0; i < visible.length; i++) {
        final assistant = visible[i];
        final emoji = assistant.emoji;
        if (emoji != null && emoji.isNotEmpty) {
          children.add(Text(emoji, style: const TextStyle(fontSize: 18)));
        } else {
          children.add(Icon(Icons.smart_toy_outlined, size: 16, color: textColor));
        }
        if (i != visible.length - 1) {
          children.add(const SizedBox(width: 4));
        }
      }
      children.add(const SizedBox(width: 6));

      final label =
          assistants.length == 1 ? assistants.first.name : '${assistants.length} 个助手';
      children.add(
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: background,
          border: Border.all(
            color: borderColor,
            width: 0.7,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
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
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        width: 44,
        height: 44,
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
                    color: const Color(0xFF3BB554).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: enabled
            ? CherryIcons.arrowUp(size: 20)
            : Icon(
                Icons.arrow_upward_rounded,
                size: 18,
                color: Colors.white.withOpacity(0.5),
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: const Color(0xFFED6767),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.pause_circle_filled,
          color: Colors.white,
          size: 22,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? const Color(0xFF20252C) : const Color(0xFFF2F4F6),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
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
          const SizedBox(width: 8),
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

class _MentionSelector extends StatefulWidget {
  final List<AssistantModel> assistants;
  final Set<String> initialSelection;

  const _MentionSelector({
    required this.assistants,
    required this.initialSelection,
  });

  @override
  State<_MentionSelector> createState() => _MentionSelectorState();
}

class _MentionSelectorState extends State<_MentionSelector> {
  late Set<String> _selection;

  @override
  void initState() {
    super.initState();
    _selection = Set<String>.from(widget.initialSelection);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171A1F) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '选择要 @ 的助手',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.assistants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = widget.assistants[index];
                final selected = _selection.contains(item.id);
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selection.remove(item.id);
                      } else {
                        _selection.add(item.id);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: selected
                          ? (isDark ? Tokens.greenDark10 : Tokens.green10)
                          : (isDark
                              ? const Color(0xFF1C2026)
                              : const Color(0xFFF5F6F8)),
                      border: Border.all(
                        color: selected
                            ? (isDark ? Tokens.greenDark20 : Tokens.green20)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(item.emoji ?? '🤖', style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_rounded,
                              size: 18,
                              color: isDark ? Tokens.greenDark100 : Tokens.green100),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, widget.initialSelection.toList()),
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _selection.isEmpty
                      ? null
                      : () => Navigator.pop(context, _selection.toList()),
                  child: const Text('完成'),
                ),
              ),
            ],
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


