import 'package:flutter/widgets.dart';

import '../demo_state.dart';

/// Đây là NavigatorObserver của Flutter, được gắn vào GoRouter/ShellRoute.
/// Nó theo dõi thay đổi Page trên Navigator, không phải mọi thay đổi query URL.
/// Dùng cho log, analytics hoặc gỡ lỗi; không gọi go/push từ observer này.
class DemoNavigatorObserver extends NavigatorObserver {
  DemoNavigatorObserver(this.label, this.journal);

  final String label;
  final NavigationJournal journal;

  String _name(Route<dynamic>? route) => route?.settings.name ?? '(không tên)';

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    journal.record('$label PUSH ${_name(route)}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    journal.record('$label POP ${_name(route)} → ${_name(previousRoute)}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    journal.record('$label REPLACE ${_name(oldRoute)} → ${_name(newRoute)}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    journal.record('$label REMOVE ${_name(route)}');
  }
}
