import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final Future<void> Function(String text) onSubmit;
  const MessageInput({super.key, required this.onSubmit});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await widget.onSubmit(text);
      _controller.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: '输入消息…',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _sending ? null : _send,
            icon: _sending
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
