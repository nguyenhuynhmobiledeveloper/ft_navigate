import 'package:flutter/foundation.dart';

/// Trạng thái giả lập chỉ phục vụ ví dụ redirect theo đăng nhập/đăng xuất.
class DemoSession extends ChangeNotifier {
  bool signedIn = false;

  // Hàm đăng nhập thông báo đã đăng nhập
  void login() {
    signedIn = true;
    notifyListeners();
  }

  // Có thể bỏ qua thông báo nếu ngay sau đó router đã được điều hướng.
  void logout({bool notify = true}) {
    signedIn = false;
    if (notify) notifyListeners();
  }
}
