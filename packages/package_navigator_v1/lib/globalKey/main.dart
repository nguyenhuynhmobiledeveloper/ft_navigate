// Cách sử dụng MaterialPageRoute
import 'package:flutter/material.dart';
import 'app_router.dart';
import 'home_page.dart';

void main() {
  runApp(const GlobalKeyExampleApp());
}

class GlobalKeyExampleApp extends StatelessWidget {
  const GlobalKeyExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //  final navigatorKey1 = AppRouter();
    return MaterialApp(
        // Đây chính là sử dụng GlobalKeys
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            // fontFamily: Fonts.SFPro
            // fontFamily: Fonts.regular
            ),
        // navigatorKey : Sử dụng để thay thế cho context
        // Sẽ điều hướng màn hình bằng key global này
        navigatorKey: AppRouter.navigatorKey,
        home: const HomePage());
  }
}
