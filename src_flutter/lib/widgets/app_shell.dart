import 'package:flutter/material.dart';

import 'app_drawer.dart';

/// AppShell 负责提供包含 Drawer 的全局 Scaffold，并通过 [AppShellScope]
/// 暴露打开/关闭抽屉的能力，供子页面调用。
class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey(debugLabel: 'app_shell_scaffold');
  late final AppShellController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppShellController(_scaffoldKey);
  }

  @override
  Widget build(BuildContext context) {
    return AppShellScope(
      controller: _controller,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const AppDrawer(),
        body: SafeArea(
          top: true,
          bottom: false,
          child: widget.child,
        ),
      ),
    );
  }
}

class AppShellController {
  final GlobalKey<ScaffoldState> _scaffoldKey;

  AppShellController(this._scaffoldKey);

  void openDrawer() => _scaffoldKey.currentState?.openDrawer();
  void closeDrawer() => _scaffoldKey.currentState?.closeDrawer();
  bool get isDrawerOpen => _scaffoldKey.currentState?.isDrawerOpen ?? false;
}

class AppShellScope extends InheritedWidget {
  final AppShellController controller;

  const AppShellScope({
    super.key,
    required this.controller,
    required super.child,
  });

  static AppShellController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppShellScope>()?.controller;

  static AppShellController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'AppShellScope 未在当前上下文中找到，请确保处于 AppShell 内部。');
    return controller!;
  }

  @override
  bool updateShouldNotify(covariant AppShellScope oldWidget) => false;
}

extension AppShellExtensions on BuildContext {
  AppShellController? get appShell => AppShellScope.maybeOf(this);
}
