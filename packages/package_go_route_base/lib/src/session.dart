import 'package:flutter/foundation.dart';

/// Trạng thái giả lập chỉ phục vụ ví dụ redirect theo đăng nhập/đăng xuất.
class DemoSession extends ChangeNotifier {
  bool signedIn = false;

  // Hàm đăng nhập thông báo đã đăng nhập
  void login() {
    signedIn = true;
    notifyListeners();
  }

  // Hàm đăng xuất thông báo trạng thái đã đăng xuất
  void logout() {
    signedIn = false;
    notifyListeners();
  }
}
