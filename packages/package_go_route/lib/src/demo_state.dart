import 'dart:async';

import 'package:flutter/foundation.dart';

/// Trạng thái đăng nhập giả lập, chỉ phục vụ bài học redirect.
/// App thật cần xác thực token/quyền ở server; router chỉ quyết định màn hình.
class DemoSession extends ChangeNotifier {
  bool signedIn = false;
  bool isAdmin = false;

  void signIn({bool admin = false}) {
    signedIn = true;
    isAdmin = admin;
    // GoRouter lắng nghe object này qua refreshListenable.
    // notifyListeners làm router đánh giá lại redirect dù URL chưa thay đổi.
    notifyListeners();
  }

  void signOut() {
    signedIn = false;
    isAdmin = false;
    notifyListeners();
  }
}

class DemoDraft {
  String text = '';
  bool dirty = false;
}

/// Nhật ký phục vụ màn hình quan sát NavigatorObserver.
class NavigationJournal extends ValueNotifier<List<String>> {
  NavigationJournal() : super(const []);
  bool _disposed = false;

  void record(String message) {
    // Navigator có thể gọi observer trong lúc build. Chuyển notification sang
    // microtask để tránh gọi setState gián tiếp ngay giữa quá trình build.
    scheduleMicrotask(() {
      if (!_disposed) value = [message, ...value].take(40).toList();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
