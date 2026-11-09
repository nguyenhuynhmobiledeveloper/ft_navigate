import 'package:flutter/material.dart';

import 'package:demo_ft_navigate/navigate/globalKey/app_router.dart';
import 'package:demo_ft_navigate/navigate/globalKey/HomePage.dart';

// Màn hình SecondPage : có 1 Contructor nhận 1 String
class SecondPage extends StatefulWidget {
  final String? argumentRoute;
  const SecondPage({Key? key, this.argumentRoute}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Full màn hình : 1, appBar , 2 body
      appBar: AppBar(
        title: const Text('Screen 1'), //Tiêu đề của thanh AppBar
        centerTitle: true, // Thuộc tính có căn giữa không
      ),
      body: Center(
        // widget căn giữa ra màn hình (hoặc giữa thằng widget cha của nó)
        child: Column(
          //Widget mà các children bên trong xếp theo hàng dọc
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // Column Widget  : mainAxisAlignment  là trục dọc
          children: [
            const SizedBox(
              width: 150,
              height: 150,
              child: SizedBox(height: 100, width: 100),
            ),

            //widget GoToPageButton nút ấn để khi mà ấn vào sẽ navigator vào màn hình routeName: nameScreen.routeName
            ElevatedButton(
              onPressed: () {
                // Cách để trở về màn trước
                // Navigator.of(context).pop(false);
                AppRouter.push(const HomePage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
              child: const Text(
                "Sang màn 2",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              height: 200,
              width: 200,
              color: Colors.black,
              child: InkWell(
                child: Container(
                  height: 100,
                  width: 100,
                  color: Colors.amber,
                  child: Text(widget.argumentRoute!),
                ),
                onTap: () {
                  setState(() {
                    // sideLength == 50 ? sideLength = 100 : sideLength = 50;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
