import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/llm_service.dart';

class StreamingState extends StateNotifier<Map<String, CancelToken?>> {
  StreamingState() : super({});

  CancelToken start(String topicId) {
    final token = CancelToken();
    state = {...state, topicId: token};
    return token;
  }

  void stop(String topicId) {
    final next = {...state};
    next.remove(topicId);
    state = next;
  }

  void cancel(String topicId) {
    final token = state[topicId];
    token?.cancel();
    stop(topicId);
  }

  bool isStreaming(String topicId) => state.containsKey(topicId);
}

final streamingProvider = StateNotifierProvider<StreamingState, Map<String, CancelToken?>>((ref) {
  return StreamingState();
});
