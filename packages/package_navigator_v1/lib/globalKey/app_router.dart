import 'package:flutter/material.dart';

// Class khai báo GlobalKey + các method với golbalkey đó để điều hướng màn hình
class AppRouter {
  // Biến giá trị là 1 globalKey Navigator
  static final navigatorKey = GlobalKey<NavigatorState>();

// Method quản lý màn hình bằng global key đó
  static push(Widget page) => navigatorKey.currentState?.push(
        // Cách navigate màn hình trực tiếp bằng MaterialPageRoute
        MaterialPageRoute(builder: (_) => page),
      );
}
