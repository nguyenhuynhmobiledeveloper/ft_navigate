# package_go_route_NavigationBar

Ví dụ thanh điều hướng 5 tab theo ảnh tham chiếu. Tên Dart dùng để import là `package_go_route_navigation_bar` vì tên package trong `pubspec.yaml` phải viết thường.

Thanh có **Trang chủ**, **Lịch sử**, **Đầu tư**, **Tài sản**, **Cá nhân**. Cả năm tab nằm trong `StatefulShellRoute.indexedStack`. Trong tab **Đầu tư**, nút **Chi tiết** mở màn hình phủ toàn bộ app, không có bottom bar; Back đưa về tab Đầu tư. Nội dung mỗi màn hình chỉ là text mock.

## Chạy

Từ thư mục gốc project:

```sh
flutter pub get
flutter run
```

`lib/main.dart` đã chạy `runGoRouteNavigationBarApp()`. Route và giao diện thanh tab đều nằm trong [`lib/src/app.dart`](lib/src/app.dart).

`StatefulShellRoute.indexedStack` tạo một branch cho mỗi tab. `shell.currentIndex` quyết định tab đang chọn; `shell.goBranch(index)` đổi tab. Bấm lại tab hiện tại sẽ về route gốc của tab. Route con `/invest/details` dùng `parentNavigatorKey` trỏ tới root Navigator, nên hiển thị phía trên shell. `context.push('/invest/details')` mở chi tiết và `context.pop()` đóng nó để trở lại tab Đầu tư.

## Thuộc tính thanh điều hướng

Thanh tab dùng widget Material 3 `NavigationBar` và năm `NavigationDestination`. Trong [`lib/src/app.dart`](lib/src/app.dart), ngay tại hai constructor có comment tiếng Việt cho **toàn bộ 17 tham số của `NavigationBar` và 6 tham số của `NavigationDestination`**: công dụng, giá trị mặc định, kiểu hoặc miền giá trị, và ý nghĩa các lựa chọn. Tham số đang dùng là code chạy; tham số để mặc định được viết thành dòng code comment để dễ thử. Mặc định về màu và kiểu chữ được mô tả theo `ThemeData(useMaterial3: true)` của ví dụ này.

Nguồn đối chiếu API: [NavigationBar](https://api.flutter.dev/flutter/material/NavigationBar/NavigationBar.html) và [NavigationDestination](https://api.flutter.dev/flutter/material/NavigationDestination/NavigationDestination.html).
