import 'package:flutter/material.dart';

// import 'package:demo_ft_widget/navigate/pushNamed/pushNamed.dart';

// Màn hình SecondPage
class SecondPage extends StatefulWidget {
  const SecondPage({Key? key, String? argumentRoute}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  String? argumentRoute;
  @override
  Widget build(BuildContext context) {
    // Cách Lấy params truyền từ màn khác sang
    Map<String, String>? arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

    argumentRoute = arguments!["argumentRoute"];

    return Scaffold(
      // Full màn hình : 1, appBar , 2 body
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
            const SizedBox(width: 150, height: 150),

            // widget GoToPageButton nút ấn để khi mà ấn vào sẽ navigator vào màn hình routeName: nameScreen.routeName
            ElevatedButton(
              onPressed: () {
                // Cách để trở về màn trước
                // Navigator.of(context).pop(false);  // Cách viết 1
                Navigator.pushNamed(
                  context,
                  "/",
                );
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
            Text(argumentRoute!),
          ],
        ),
      ),
    );
  }
}
