// Cách sử dụng Navigator.pushNamed(context, '/nameScreen')

import 'package:flutter/material.dart';

// Màn hình HomePage
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Flutter'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 150, height: 150),
            ElevatedButton(
              onPressed: () {
                // navigate theo tên và có truyền dữ liệu sang màn hình mới
                Navigator.pushNamed(context, "/Screen1",
                    arguments: {'argumentRoute': "ArgumentRouteContent"});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
              child: const Text(
                "Sang màn 1",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
            const Text(
              "xinchafo",
              style: TextStyle(color: Colors.amber),
            ),
          ],
        ),
      ),
    );
  }
}
