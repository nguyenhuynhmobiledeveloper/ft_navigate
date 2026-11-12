# package_go_route_base

App mẫu **go_router 17.0.1** chỉ tập trung vào những thao tác navigation hay dùng. Giao diện chỉ có chữ, nút và thanh tab. Comment tiếng Việt nằm ngay cạnh cấu hình route và lệnh điều hướng.

## Chạy

Từ thư mục gốc dự án:

```sh
flutter pub get
flutter run
```

`lib/main.dart` đã gọi `runGoRouteBaseApp()`. Có thể chạy riêng package từ thư mục này bằng một file entry point trong host app; package không có cấu hình Android/iOS riêng.

## Đọc code

1. [`lib/src/app.dart`](lib/src/app.dart): tạo `GoRouter`, khai báo URL, route lồng, tab, redirect, trang lỗi và `MaterialApp.router`.
2. [`lib/src/screens.dart`](lib/src/screens.dart): các nút gọi `go`, `push`, `pop`, `goNamed`, `pushNamed`, `goBranch`; cách đọc path/query/extra.

| Thử trong app | Kiến thức |
| --- | --- |
| Trang đầu → Chọn giá trị | `push<String>`, `pop(result)`, nhận kết quả, Back trả `null` |
| Trang đầu → Sản phẩm | `go`: tới URL theo cây route |
| Đổi query sort | `Uri`, `state.uri.queryParameters` |
| Mở sản phẩm 42 / 7 | `pushNamed` so với `goNamed`, `:id`, `state.extra` |
| Sản phẩm → Đánh giá | Route con và stack khi mở deep link |
| Đổi giữa 2 tab | `StatefulShellRoute.indexedStack`, `goBranch`, giữ stack từng tab |
| Tài khoản → Đăng nhập / Đăng xuất | `redirect` và `refreshListenable` |
| URL không tồn tại | `errorBuilder` |

Thử mở thẳng `/products/42/reviews` hoặc `/account` để thấy router dựng route cha và redirect. `extra` là dữ liệu trong bộ nhớ, vì vậy màn chi tiết luôn lấy `id` từ URL và chấp nhận `extra == null` khi mở từ deep link hoặc reload.

Ví dụ bỏ qua các API ít dùng hơn như typed routes, custom transitions, dynamic routing, observer và restoration. Package [`package_go_route`](../package_go_route/README.md) có các bài đó.

Tài liệu: [go_router navigation](https://pub.dev/documentation/go_router/17.0.1/topics/Navigation-topic.html), [configuration](https://pub.dev/documentation/go_router/17.0.1/topics/Configuration-topic.html), [redirection](https://pub.dev/documentation/go_router/17.0.1/topics/Redirection-topic.html).
