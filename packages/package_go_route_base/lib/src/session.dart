import 'package:flutter/foundation.dart';

/// Trạng thái giả lập chỉ phục vụ ví dụ redirect theo đăng nhập/đăng xuất.
class DemoSession extends ChangeNotifier {
  bool signedIn = false;

  void login() {
    signedIn = true;
    notifyListeners();
  }

  void logout() {
    signedIn = false;
    notifyListeners();
  }
}
