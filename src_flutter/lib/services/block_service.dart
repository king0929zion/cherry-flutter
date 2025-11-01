import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/boxes.dart';
import '../models/block.dart';
import '../utils/ids.dart';
import 'dart:convert';

class BlockService {
  Future<Block> upsertTranslation({required String messageId, required String text}) async {
    // one translation per message; overwrite if exists
    final existing = await getTranslationForMessage(messageId);
    final block = Block(
      id: existing?.id ?? newId(),
      messageId: messageId,
      type: BlockType.translation,
      content: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await Boxes.blocks.put(block.id, block.toJson());
    return block;
  }

  Future<Block?> getTranslationForMessage(String messageId) async {
    for (final key in Boxes.blocks.keys) {
      final m = Boxes.blocks.get(key) as Map?;
      if (m == null) continue;
      if (m['messageId'] == messageId && m['type'] == BlockType.translation.name) {
        return Block.fromJson(m as Map<String, dynamic>);
      }
    }
    return null;
  }

  Future<List<Block>> getAttachmentsForMessage(String messageId) async {
    final res = <Block>[];
    for (final key in Boxes.blocks.keys) {
      final m = Boxes.blocks.get(key) as Map?;
      if (m == null) continue;
      if (m['messageId'] == messageId && (m['type'] == BlockType.image.name || m['type'] == BlockType.file.name)) {
        res.add(Block.fromJson(Map<String, dynamic>.from(m)));
      }
    }
    res.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return res;
  }

  Future<Block> addAttachmentBlock({
    required String messageId,
    required String name,
    required String mime,
    required List<int> bytes,
  }) async {
    final isImage = mime.startsWith('image/');
    final payload = jsonEncode({
      'name': name,
      'mime': mime,
      'size': bytes.length,
      'data': base64Encode(bytes),
    });
    final block = Block(
      id: newId(),
      messageId: messageId,
      type: isImage ? BlockType.image : BlockType.file,
      content: payload,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await Boxes.blocks.put(block.id, block.toJson());
    return block;
  }
}

final blockServiceProvider = Provider<BlockService>((ref) => BlockService());

final translationBlockProvider = FutureProvider.family<Block?, String>((ref, messageId) async {
  return ref.read(blockServiceProvider).getTranslationForMessage(messageId);
});

final attachmentsProvider = FutureProvider.family<List<Block>, String>((ref, messageId) async {
  return ref.read(blockServiceProvider).getAttachmentsForMessage(messageId);
});
