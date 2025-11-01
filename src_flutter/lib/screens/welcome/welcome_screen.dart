import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_state.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('欢迎使用 Cherry Flutter'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await ref.read(welcomeShownProvider.notifier).setShown(true);
              },
              child: const Text('开始使用'),
            )
          ],
        ),
      ),
    );
  }
}
