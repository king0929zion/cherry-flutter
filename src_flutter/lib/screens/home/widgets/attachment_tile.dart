import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../models/block.dart';

class AttachmentTile extends StatelessWidget {
  final Block block;
  const AttachmentTile({required this.block});

  @override
  Widget build(BuildContext context) {
    try {
      final map = jsonDecode(block.content) as Map<String, dynamic>;
      final name = map['name'] as String? ?? 'file';
      final mime = map['mime'] as String? ?? 'application/octet-stream';
      final size = map['size'] as int? ?? 0;
      final data = map['data'] as String?;
      if (block.type == BlockType.image && data != null) {
        final bytes = base64Decode(data);
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Image.memory(Uint8List.fromList(bytes), width: 220, fit: BoxFit.cover),
        );
      }
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(8),
        decoration:
            BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file, color: Colors.white70),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text('$name (${(size / 1024).toStringAsFixed(1)} KB)',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}
