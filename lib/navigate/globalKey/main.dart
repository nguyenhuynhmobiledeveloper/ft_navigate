// Cách sử dụng MaterialPageRoute
import 'package:flutter/material.dart';
import 'package:demo_ft_navigate/navigate/globalKey/app_router.dart';
import 'package:demo_ft_navigate/navigate/globalKey/HomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        home: HomePage());
  }
}
