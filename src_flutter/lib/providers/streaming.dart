import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/llm_service.dart';

class StreamingState extends Notifier<Map<String, CancelToken?>> {
  @override
  Map<String, CancelToken?> build() => <String, CancelToken?>{};

  CancelToken start(String topicId) {
    final token = CancelToken();
    state = {...state, topicId: token};
    return token;
  }

  void stop(String topicId) {
    final next = Map<String, CancelToken?>.from(state);
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

final streamingProvider = NotifierProvider<StreamingState, Map<String, CancelToken?>>(StreamingState.new);
