# Flutter navigation examples

Dự án thực hành điều hướng Flutter. App mặc định hiện chạy [`package_go_route_base`](packages/package_go_route_base/README.md): ví dụ `go_router` ngắn gọn, tập trung vào các API navigation thường dùng. Comment giải thích chi tiết nằm cạnh cấu hình route và từng nút điều hướng.

```sh
flutter pub get
flutter run
```

Các ví dụ khác trong repo:

- [`package_go_route`](packages/package_go_route/README.md): các API `go_router` nâng cao.
- [`package_navigator_v1`](packages/package_navigator_v1/README.md): Navigator 1.0.

Để chạy một ví dụ khác, đổi hàm `main()` trong [`lib/main.dart`](lib/main.dart) sang hàm khởi động của package đó.
