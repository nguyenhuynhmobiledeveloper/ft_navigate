import 'package:flutter/material.dart';

import 'home_page.dart';
import 'second_page.dart';

void main() {
  runApp(const PushNamed());
}

class PushNamed extends StatelessWidget {
  const PushNamed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // fontFamily: Fonts.SFPro
          // fontFamily: Fonts.regular
          ),

      //Danh sách các màn hình mà có thể chuyển Navigator sang
      routes: routesList,
      // Màn hình mặc định khi khởi tạo app là chạy lên
      initialRoute: "/",
    );
  }
}

// Map danh sách các màn hình có thể chuyển qua chuyển lại trong ứng dụng : get routeList => {}
Map<String, WidgetBuilder> get routesList => {
      "/": (context) => const HomePage(),
      "/Screen1": (context) => const SecondPage(),
    };
