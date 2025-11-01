import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String topicId;
  const ChatScreen({super.key, required this.topicId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Chat Screen - topicId: $topicId'),
      ),
    );
  }
}
