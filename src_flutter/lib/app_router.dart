import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/app_state.dart';
import 'widgets/app_drawer.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/home/chat_screen.dart';
import 'screens/topic/topic_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/general_settings_screen.dart';
import 'screens/settings/assistant_settings_screen.dart';
import 'screens/settings/providers_settings_screen.dart';
import 'screens/settings/data_sources_settings_screen.dart';
import 'screens/settings/web_search_settings_screen.dart';
import 'screens/settings/about/about_screen.dart';
import 'screens/assistant/assistant_screen.dart';
import 'screens/assistant/assistant_market_screen.dart';
import 'screens/assistant/assistant_detail_screen.dart';
import 'screens/mcp/mcp_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  final welcomeShown = ref.watch(welcomeShownProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home/chat/default',
    redirect: (context, state) {
      final loggingInWelcome = state.matchedLocation.startsWith('/welcome');
      if (!welcomeShown && !loggingInWelcome) {
        return '/welcome';
      }
      if (welcomeShown && loggingInWelcome) {
        return '/home/chat/default';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/welcome', builder: (ctx, st) => const WelcomeScreen()),
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cherry Flutter')),
            drawer: const AppDrawer(),
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home/chat/:topicId',
            builder: (ctx, st) => ChatScreen(topicId: st.pathParameters['topicId'] ?? 'default'),
          ),
          GoRoute(path: '/home/topic', builder: (ctx, st) => const TopicScreen()),
          GoRoute(
            path: '/settings',
            builder: (ctx, st) => const SettingsScreen(),
            routes: [
              GoRoute(path: 'general', builder: (ctx, st) => const GeneralSettingsScreen()),
              GoRoute(path: 'assistant', builder: (ctx, st) => const AssistantSettingsScreen()),
              GoRoute(path: 'providers', builder: (ctx, st) => const ProvidersSettingsScreen()),
              GoRoute(path: 'data-sources', builder: (ctx, st) => const DataSourcesSettingsScreen()),
              GoRoute(path: 'web-search', builder: (ctx, st) => const WebSearchSettingsScreen()),
              GoRoute(path: 'about', builder: (ctx, st) => const AboutScreen()),
            ],
          ),
          GoRoute(path: '/assistant', builder: (ctx, st) => const AssistantScreen()),
          GoRoute(path: '/assistant/market', builder: (ctx, st) => const AssistantMarketScreen()),
          GoRoute(
            path: '/assistant/:assistantId',
            builder: (ctx, st) => AssistantDetailScreen(assistantId: st.pathParameters['assistantId']!),
          ),
          GoRoute(path: '/mcp', builder: (ctx, st) => const McpScreen()),
        ],
      ),
    ],
  );
});
