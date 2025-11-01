import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/attachment.dart';

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

class MessageInput extends StatefulWidget {
  final Future<void> Function(String text, List<PickedAttachment> attachments) onSubmit;
  const MessageInput({super.key, required this.onSubmit});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  bool _sending = false;
  final List<PickedAttachment> _attachments = [];

  Future<void> _send() async {
    final text = _controller.text.trim();
    if ((text.isEmpty && _attachments.isEmpty) || _sending) return;
    setState(() => _sending = true);
    try {
      await widget.onSubmit(text, List.unmodifiable(_attachments));
      _controller.clear();
      _attachments.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickFiles() async {
    final res = await FilePicker.platform.pickFiles(allowMultiple: true, withData: true);
    if (res == null) return;
    for (final f in res.files) {
      if (f.bytes == null) continue;
      _attachments.add(PickedAttachment(name: f.name, mime: _guessMime(f.name), bytes: f.bytes!));
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          if (_attachments.isNotEmpty)
            SizedBox(
              height: 56,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) {
                  final a = _attachments[i];
                  return Chip(
                    label: Text(a.name, overflow: TextOverflow.ellipsis),
                    onDeleted: () => setState(() => _attachments.removeAt(i)),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: _attachments.length,
              ),
            ),
          Row(
            children: [
              IconButton(onPressed: _sending ? null : _pickFiles, icon: const Icon(Icons.attach_file)),
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
        ],
      ),
    );
  }
}
