import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// import 'providers/app_state.dart'; // welcome 已移除
import 'widgets/app_shell.dart';
// import 'screens/welcome/welcome_screen.dart';
import 'screens/home/chat_screen.dart';
import 'screens/topic/topic_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/general_settings_screen.dart';
import 'screens/settings/assistant_settings_screen.dart';
import 'screens/settings/providers_settings_screen.dart';
import 'screens/settings/model_settings_screen.dart';
import 'screens/settings/datasource_settings_screen.dart';
import 'screens/settings/websearch_settings_screen.dart';
import 'screens/settings/about/about_screen.dart';
import 'screens/settings/personal_settings_screen.dart';
import 'screens/assistant/assistant_screen.dart';
import 'screens/assistant/assistant_market_screen.dart';
import 'screens/assistant/assistant_detail_screen.dart';
import 'screens/mcp/mcp_screen.dart';
import 'screens/mcp/mcp_market_screen.dart';
import 'screens/mcp/mcp_server_editor_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home/chat/default',
    // 移除欢迎页重定向逻辑，首次进入直接进入主界面
    routes: [
      // GoRoute(path: '/welcome', builder: (ctx, st) => const WelcomeScreen()),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
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
              GoRoute(path: 'models', builder: (ctx, st) => const ModelSettingsScreen()),
              GoRoute(path: 'data-sources', builder: (ctx, st) => const DataSourceSettingsScreen()),
              GoRoute(path: 'web-search', builder: (ctx, st) => const WebSearchSettingsScreen()),
              GoRoute(path: 'about', builder: (ctx, st) => const AboutScreen()),
              GoRoute(path: 'about/personal', builder: (ctx, st) => const PersonalSettingsScreen()),
            ],
          ),
          GoRoute(path: '/assistant', builder: (ctx, st) => const AssistantScreen()),
          GoRoute(path: '/assistant/market', builder: (ctx, st) => const AssistantMarketScreen()),
          GoRoute(
            path: '/assistant/:assistantId',
            builder: (ctx, st) => AssistantDetailScreen(assistantId: st.pathParameters['assistantId']!),
          ),
          GoRoute(
            path: '/mcp',
            builder: (ctx, st) => const McpScreen(),
            routes: [
              GoRoute(
                path: '/market',
                builder: (ctx, st) => const McpMarketScreen(),
              ),
              GoRoute(
                path: '/editor/:serverId?',
                builder: (ctx, st) => McpServerEditorScreen(
                  serverId: st.pathParameters['serverId'],
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
