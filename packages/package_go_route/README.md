# package_go_route

App thực hành điều hướng nhiều màn hình bằng **`go_router`**. Tên package nội bộ là
`package_go_route`; dependency chính xác trên pub.dev là `go_router`, không phải
`go_route`.

UI chỉ gồm Scaffold, chữ, nút, trường nhập và thanh tab. Phần cần học nằm trong
comment tiếng Việt cạnh từng cấu hình route và lời gọi navigation.

## Chạy app

Tại thư mục dự án `ft_navigate`:

```sh
flutter pub get
flutter run
```

`lib/main.dart` của dự án đã dùng:

```dart
import 'package:package_go_route/package_go_route.dart';

void main() => runPackageGoRouteApp();
```

Package ghim **go_router 17.0.1**, yêu cầu Flutter >=3.35 và Dart >=3.9 theo
`pubspec.yaml` của dependency được cài.
Mã đã được kiểm tra với Dart 3.9.2 của SDK trong dự án. Ghim phiên bản giúp comment,
test và hành vi API khớp nhau; đây không phải tuyên bố dùng phiên bản mới nhất.

## Đọc code theo thứ tự

1. [`lib/app.dart`](lib/app.dart): vòng đời router, `MaterialApp.router`, restoration.
2. [`demo_navigation.dart`](lib/src/routing/demo_navigation.dart): toàn bộ cây route,
   navigator keys, redirect, guard và shell. Đây là file trung tâm của bài học.
3. [`home_screen.dart`](lib/src/screens/home_screen.dart): mục lục, mỗi nút mở một bài.
4. Các file `screens/`: xem lời gọi navigation ngay tại nút mà bạn vừa bấm.
5. [`REFERENCE.md`](REFERENCE.md): bảng so sánh API, các lựa chọn cấu hình khác và lưu ý.
6. [`test/navigation_test.dart`](test/navigation_test.dart): các tình huống có thể
   chạy tự động, đặc biệt deep link, auth, Back, tab state và restoration.

## Tính năng và nơi thực hành

| Kiến thức | Màn hình / thao tác | File chính |
| --- | --- | --- |
| `GoRouter`, `GoRoute`, `MaterialApp.router` | Mở app | `app.dart`, `routing/demo_navigation.dart` |
| `go`, `push`, `pop<T>`, `canPop` | Mục 1 → chọn và trả kết quả | `screens/stack_screens.dart` |
| `replace`, `pushReplacement`, Page key | Tăng bộ đếm bước rồi thay trang | `screens/stack_screens.dart` |
| Tương thích `Navigator.push` | Trang tạm trong mục 1 | `screens/stack_screens.dart` |
| Path/query, URL encoding, query lặp, fragment | Mục 2 và 12 | `catalog_screens.dart`, `advanced_screens.dart` |
| `name`, `goNamed`, `pushNamed`, `namedLocation` | Danh sách → chi tiết → reviews | `catalog_screens.dart`, `routing/route_names.dart` |
| `extra`, `extraCodec`, fallback khi thiếu extra | Nút `pushNamed + extra object` | `catalog_screens.dart`, `routing/extra_codec.dart` |
| Route cha/con, deep link tạo đủ stack | `/products/1/reviews` | `routing/demo_navigation.dart` |
| Đường dẫn tương đối `./reviews` | Chi tiết sản phẩm | `catalog_screens.dart` |
| `ShellRoute`, `parentNavigatorKey` | Mục 3 → trang phủ shell | `shell_screens.dart`, `routing/demo_navigation.dart` |
| `StatefulShellRoute`, `StatefulShellBranch`, `goBranch` | Mục 4 → tăng bộ đếm, mở chi tiết, đổi tab | `shell_screens.dart` |
| `redirect`, `refreshListenable`, return URL | Mục 5 → login, logout | `auth_screens.dart`, `demo_state.dart` |
| Guard quyền trên route đích | Tài khoản → quản trị | `routing/demo_navigation.dart` |
| `onExit`, async confirmation | Mục 6 → nhập chữ rồi Back/Home | `guard_screens.dart` |
| `pageBuilder`, `CustomTransitionPage`, `NoTransitionPage`, `CupertinoPage` | Mục 7–9 | `routing/demo_navigation.dart` |
| `GoRouteData`, `TypedGoRoute`, code generation | Mục 10 | `routing/typed_routes.dart` và file `.g.dart` |
| State restoration + `RestorableInt` | Mục 11 | `stack_screens.dart`, `app.dart` |
| `onEnter`, `Allow`, `Block.stop` | Mục 12 → bật/tắt quyền vào `/guarded` | `routing/demo_navigation.dart` |
| `RoutingConfig`, đổi cây route lúc chạy | Mục 12 → bật `/experimental` | `routing/demo_navigation.dart` |
| `errorBuilder`, URL sai, redirect loop | Mục 12 → thử lỗi | `advanced_screens.dart` |
| `GoRouterState`, `NavigatorObserver`, diagnostics | Mục 13 | `widgets/study_page.dart`, `routing/navigation_observer.dart` |
| `Router.neglect`, `refresh`, gọi router không cần context | Mục 12 | `advanced_screens.dart` |

Các đường dẫn trong bảng tính từ `lib/src/`, trừ `app.dart`.

## Cây route

```text
/                                mục lục
/stack                           push/pop, kết quả
  /step/:step                    replace/pushReplacement
/pick                            trả String qua pop
/products                        query sort/q
  /:id                           path parameter + optional extra
    /reviews                     route lồng cấp 3
/login                           nhận query from
/account                         cần đăng nhập
/admin                           cần quyền admin
/forbidden                       không đủ quyền
/editor                          onExit xác nhận bỏ bản nháp
/transition                      CustomTransitionPage
/no-transition                   NoTransitionPage
/cupertino                       CupertinoPage, fullscreenDialog
/typed-book/:bookId?page=2        route generated, int path/query
/bad-link                        dữ liệu typed URL không hợp lệ
/restore                         restoration counter
/advanced                        các bài nâng cao
/inspect                         GoRouterState và nhật ký Navigator
/guarded                         onEnter có thể chặn
/legacy                          redirect sang /products/1
/loop-a ↔ /loop-b                 vòng lặp cố ý để thử errorBuilder
/experimental                    chỉ được đăng ký khi bật feature
ShellRoute
  /workspace
    /settings                    vẫn ở Navigator của shell
    /full-screen                 đặt trên root Navigator, che shell
StatefulShellRoute.indexedStack
  branch feed: /tabs/feed
    /item/:id
  branch saved: /tabs/saved
    /item/:id
```

## Những bài nên bấm thử

1. **Stack:** mở mục 1, `push` trang chọn, chọn Flutter. Trang gọi nhận được String.
   Bấm Back ở trang chọn thay vì chọn sẽ nhận null và hiển thị “Đã hủy”.
2. **Page identity:** push bước 1, tăng bộ đếm, `replace` bước 2: bộ đếm còn.
   `pushReplacement` bước 3: bộ đếm về 0. Đọc comment về `state.pageKey`.
3. **Nested route:** mở trực tiếp `/products/1/reviews`, rồi Back hai lần. Router
   vẫn tạo được chi tiết và danh sách phía dưới mà không cần đi từ trang chủ.
4. **Extra:** mở sản phẩm bằng nút có extra, rồi mở lại URL không có extra. Màn hình
   vẫn hoạt động nhờ dùng id trên URL để lấy dữ liệu mẫu.
5. **Shell:** mở workspace, tới cài đặt, rồi mở trang phủ toàn bộ shell. Back sẽ
   hiển thị lại thanh điều hướng shell.
6. **Tab:** tăng bộ đếm feed, mở chi tiết, đổi sang saved rồi về feed. Chi tiết còn
   trên stack; bấm lại tab feed để về gốc, bộ đếm vẫn còn.
7. **Auth:** vào `/account?source=home` khi chưa đăng nhập. Sau login, query source
   vẫn còn. User thường vào admin sẽ thấy “Không có quyền”; admin vào được.
8. **Guard rời route:** nhập bản nháp, thử cả nút Home, `go` và Back hệ thống.
   “Ở lại” giữ route; “Rời đi” cho chuyển màn hình.
9. **Guard vào route:** ở mục 12, thử `/guarded` trước và sau khi bật công tắc.
   `Block.stop` không chuyển URL; dòng log giải thích quyết định.
10. **Route động:** thử `/experimental` khi chưa bật sẽ ra trang lỗi. Về mục 12,
    bật feature rồi thử lại. Không cần tạo lại GoRouter.
11. **Restoration:** tăng bộ đếm ở mục 11. Widget test `restartAndRestore` xác minh
    cả location và giá trị được khôi phục. Hot reload không mô phỏng restoration.

## Deep link trên web và điện thoại

Chạy `flutter run -d chrome`, lấy origin/port do Flutter in ra, rồi mở:

```text
http://localhost:<port>/#/products/1/reviews?page=2
http://localhost:<port>/#/account?source=web
```

App dùng hash URL mặc định. `initialLocation` không ghi đè deep link của platform.
`go` phù hợp cho đích có thể chia sẻ trên web; lịch sử browser của các thao tác
imperative như `push` không hoàn toàn tương đương stack Navigator.

Host app đã thêm custom scheme mẫu vào `android/app/src/main/AndroidManifest.xml`
và `ios/Runner/Info.plist`. Sau khi build/cài app, thử:

```sh
# Android emulator hoặc máy đã kết nối adb
adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d 'goroutedemo://demo/products/1/reviews'

# iOS simulator đang boot và đã cài app
xcrun simctl openurl booted 'goroutedemo://demo/account?source=mobile'
```

Custom scheme này dành cho demo. HTTPS App Links / Universal Links cần thêm tên
miền, association file và cấu hình ký app; không được thiết lập chỉ bằng GoRoute.
Package mang sang host app khác cần host đó khai báo deep link tương ứng.

Widget test mô phỏng URL platform cả khi mở app lẫn khi app đang chạy. Kiểm thử
widget không xác minh việc hệ điều hành đã đăng ký scheme; cần dùng lệnh trên
trên simulator/thiết bị để kiểm tra lớp native.

## Sinh lại typed routes

File `typed_routes.g.dart` đã được sinh và đưa vào source, nên host không cần chạy
codegen chỉ để mở app. Sau khi sửa annotation/constructor typed route:

```sh
cd packages/package_go_route
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

`go_router_builder` và `build_runner` là dev dependency của package, không phải
dependency runtime của app. Không sửa file generated bằng tay.

## Kiểm tra

```sh
# Trong packages/package_go_route
flutter analyze
flutter test

# Trong thư mục gốc ft_navigate
flutter analyze
flutter test
flutter build web
```

Test ở root kiểm tra entry point chạy package mới và giữ các bài Navigator 1.0.
Test trong package kiểm tra hành vi chi tiết; `flutter test` ở root không tự chạy
test nằm bên trong mọi package con.

## Phạm vi ví dụ

Auth, sản phẩm và bản nháp đều dùng dữ liệu trong bộ nhớ. Phần này giữ code UI và
nghiệp vụ nhỏ để dễ tập trung vào router. Tab dùng bộ đếm int để minh họa giữ state
trong RAM; bài restoration dùng RestorableInt để minh họa khôi phục qua OS.

Các tính năng chính đều có đường đi thực hành. Những API thay thế nhau (ví dụ
`errorBuilder` / `errorPageBuilder` / `onException`) và các biến thể codegen được
giải thích riêng trong [REFERENCE.md](REFERENCE.md), không cấu hình chồng lên nhau.

Tài liệu gốc: [go_router 17.0.1](https://pub.dev/packages/go_router/versions/17.0.1),
[API](https://pub.dev/documentation/go_router/17.0.1/),
[go_router_builder 4.1.1](https://pub.dev/packages/go_router_builder/versions/4.1.1),
[Flutter deep linking](https://docs.flutter.dev/ui/navigation/deep-linking).
