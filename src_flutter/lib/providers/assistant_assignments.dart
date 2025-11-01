import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/boxes.dart';
import '../services/assistant_service.dart';

final assistantAssignmentsProvider = StreamProvider<Map<String, String?>>((ref) async* {
  final assistants = await ref.watch(assistantsProvider.future);
  final service = ref.read(assistantServiceProvider);
  await service.ensureAssignments(assistants);

  Map<String, String?> read() => service.readAssignments();

  final controller = StreamController<Map<String, String?>>();
  void emit() => controller.add(read());
  emit();

  final subscriptions = <StreamSubscription<dynamic>>[];
  for (final key in AssistantService.assignmentKeys.values) {
    subscriptions.add(
      Boxes.prefs.watch(key: key).listen((_) => emit()),
    );
  }

  ref.onDispose(() {
    for (final sub in subscriptions) {
      sub.cancel();
    }
    controller.close();
  });

  yield* controller.stream;
});
