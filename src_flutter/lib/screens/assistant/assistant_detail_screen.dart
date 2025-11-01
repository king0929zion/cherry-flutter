import 'package:flutter/material.dart';

class AssistantDetailScreen extends StatelessWidget {
  final String assistantId;
  const AssistantDetailScreen({super.key, required this.assistantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Assistant Detail: $assistantId')),
    );
  }
}
