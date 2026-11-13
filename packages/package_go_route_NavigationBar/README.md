# package_go_route_NavigationBar

Ví dụ thanh điều hướng 5 tab theo ảnh tham chiếu. Tên Dart dùng để import là `package_go_route_navigation_bar` vì tên package trong `pubspec.yaml` phải viết thường.

Các tab: **Trang chủ**, **Lịch sử**, **Đầu tư**, **Tài sản**, **Cá nhân**. Nút **Đầu tư** nổi trên thanh và có cùng hành vi chuyển tab như bốn nút còn lại. Nội dung mỗi màn hình chỉ là một dòng chữ mock.

## Chạy

Từ thư mục gốc project:

```sh
flutter pub get
flutter run
```

`lib/main.dart` đã chạy `runGoRouteNavigationBarApp()`. Route và giao diện thanh tab đều nằm trong [`lib/src/app.dart`](lib/src/app.dart).

`StatefulShellRoute.indexedStack` tạo một branch cho mỗi tab. `shell.currentIndex` quyết định tab đang chọn; `shell.goBranch(index)` đổi tab qua `go_router`. Bấm lại tab hiện tại sẽ về route gốc của tab đó.
