import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Assistant Screen'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/assistant/market'),
              child: const Text('Open Market'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/assistant/demo123'),
              child: const Text('Open Assistant Detail'),
            ),
          ],
        ),
      ),
    );
  }
}
