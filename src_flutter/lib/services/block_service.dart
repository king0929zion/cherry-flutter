import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/boxes.dart';
import '../models/block.dart';
import '../utils/ids.dart';

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
}

final blockServiceProvider = Provider<BlockService>((ref) => BlockService());

final translationBlockProvider = FutureProvider.family<Block?, String>((ref, messageId) async {
  return ref.read(blockServiceProvider).getTranslationForMessage(messageId);
});
