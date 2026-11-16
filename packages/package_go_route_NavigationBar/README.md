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
