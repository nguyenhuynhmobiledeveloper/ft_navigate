# Ghi chú API go_router

Tham chiếu cho phiên bản **17.0.1** dùng trong app. Ví dụ thực thi nằm trong `lib/`;
các đoạn cấu hình thay thế bên dưới là hướng dẫn để thử thêm, không phải route
được app tự động bật. Khi đổi phiên bản, đọc migration guide trước khi áp dụng.

## Các lớp làm việc với nhau thế nào

`MaterialApp.router` nhận `GoRouter` qua `routerConfig`. GoRouter triển khai cấu hình
Flutter Router: đọc route information, match URL, redirect và tạo danh sách Page
cho Navigator. `GoRoute` là một cấu hình đích. `GoRouterState` là dữ liệu của lần
match; `Page` quyết định identity/transition; Widget là nội dung màn hình.

`ShellRoute` và `StatefulShellRoute` cũng là `RouteBase`, nhưng có vai trò tạo
Navigator/khung dùng chung. Không dùng chúng như một URL đích độc lập; điều hướng
đến GoRoute nằm trong shell.

## Chọn lệnh điều hướng

| Lệnh | Công dụng | Điểm cần nhớ |
| --- | --- | --- |
| `go(location)` | Dựng stack phù hợp cây route đích | Không phải lúc nào cũng chỉ có một trang; route con tạo cả trang cha |
| `push<T>(location)` | Thêm trang vào stack hiện tại | Trả Future<T?>, dùng khi cần đợi kết quả |
| `pop<T>(value)` | Bỏ trang trên cùng, trả giá trị | T phải khớp kiểu kết quả nơi push; Back thường trả null |
| `canPop()` | Kiểm tra có route để pop không | Không hứa rằng onExit sẽ cho phép rời |
| `pushReplacement(location)` | Thay trang trên cùng, tạo page key mới | State của trang cũ thường bị bỏ; không có bước Back về trang đã thay |
| `replace(location)` | Thay location của trang trên cùng, giữ page key | State được giữ nếu Widget/Page identity tương thích |
| `goNamed`, `pushNamed<T>` | Tạo location từ route name rồi go/push | Truyền đủ pathParameters; queryParameters là tùy chọn |
| `pushReplacementNamed`, `replaceNamed` | Biến thể dùng name của hai lệnh thay trang | Quy tắc stack/key giống bản dùng location |
| `namedLocation` | Tạo chuỗi URL từ name và tham số | Không tự điều hướng |
| `goBranch(index)` | Chọn branch trong StatefulShellRoute | Khôi phục stack riêng của tab |
| `goBranch(index, initialLocation: true)` | Trở về initialLocation của branch | Hữu ích khi bấm lại tab hiện tại |
| `refresh()` | Yêu cầu router đánh giá lại route/redirect | Không tự refresh API/repository |

`context.go(...)` là extension tiện ích gọi router gần context đó.
`GoRouter.of(context).go(...)` tương đương. Code không có context có thể nhận
GoRouter qua constructor rồi gọi `router.go(...)`; không giữ context của màn hình
đã dispose. Sau `await push`, kiểm tra `mounted` trước setState/dùng context.

## Dữ liệu route

| Thành phần | Ví dụ | Dùng cho |
| --- | --- | --- |
| `pathParameters` | `/products/:id` → id=1 | Định danh tài nguyên bắt buộc |
| `state.uri.queryParameters` | `?sort=desc&q=Flutter` | Bộ lọc/tùy chọn có thể chia sẻ |
| `state.uri.queryParametersAll` | `?tag=a&tag=b` | Nhiều giá trị cho cùng một key |
| `state.uri.fragment` | `#vi-du` | Định danh phần nội dung; app tự quyết định cuộn/hiển thị |
| `state.extra` | Object ProductPreview | Dữ liệu bổ sung ngoài URL |
| `state.name` | `product` | Tên route được match |
| `state.matchedLocation` | `/products/1` | Phần location đã match tới route này |
| `state.fullPath` | `/products/:id` | Mẫu đường dẫn đầy đủ |
| `state.pageKey` | ValueKey do router tạo | Identity của Page khi tự viết pageBuilder |
| `state.error` | GoException | Lỗi routing được chuyển tới trang xử lý lỗi |

Path/query đến từ bên ngoài phải được kiểm tra. Không đặt token/password trong
URL vì URL có thể nằm trong lịch sử và log. `extraCodec` giúp tuần tự hóa object
nhưng không biến extra thành một phần URL chia sẻ được. App dùng id để xử lý khi
extra vắng. `GoRouterState.of(context)` giúp widget phụ thuộc state route; đọc
`router.state` một lần không tự làm widget rebuild khi location đổi.

## Cấu hình GoRouter

| Tùy chọn | Vai trò |
| --- | --- |
| `routes` | Cây RouteBase cố định |
| `routingConfig` constructor | Lắng nghe ValueListenable<RoutingConfig> để cập nhật cây route |
| `navigatorKey` | Key của Navigator gốc, dùng làm parentNavigatorKey khi cần |
| `initialLocation` | Đích mặc định nếu platform không đưa deep link |
| `overridePlatformDefaultLocation` | Cho phép initialLocation ghi đè location platform; không bật trong app demo |
| `initialExtra` | Extra kèm initialLocation; phải có initialLocation |
| `refreshListenable` | Kích hoạt đánh giá route khi trạng thái ngoài router đổi |
| `redirect`, `redirectLimit` | Chuyển sang URL khác và giới hạn chuỗi redirect |
| `onEnter` | Quyết định cho phép/chặn trước khi xử lý redirect |
| `extraCodec` | Serialize/deserialize extra phức tạp |
| `debugLogDiagnostics` | In bảng route và thông tin xử lý ra console |
| `observers` | Theo dõi push/pop/replace/remove Page |
| `restorationScopeId` | Tham gia cơ chế restoration của Flutter |
| `routerNeglect` | Bỏ thêm browser-history entry cho toàn router |
| `requestFocus` | Có tự request focus khi route mới xuất hiện hay không |

App dùng `GoRouter.routingConfig`, nên `routes`, `onEnter`, `redirect` và
`redirectLimit` được đặt trong object `RoutingConfig`. Các thiết lập khác nằm
trong constructor router. Giữ router và navigator keys ổn định qua các lần build.

## Redirect và guard

Chuỗi xử lý vào route của phiên bản này: `onEnter` → top-level `redirect` →
route-level `GoRoute.redirect`. Top-level redirect không tự chạy lặp lại cho URL
mà chính nó trả về. Vì vậy ví dụ kiểm tra dữ liệu của return URL ngay trong cùng
callback, và đặt kiểm tra quyền admin trong redirect của route `/admin`.

- `redirect` trả `null`: tiếp tục; trả URL khác: chuyển đích. Có thể async.
- `Allow()`: cho tiếp tục vào route. `Allow(then: ...)` chạy hành động sau quyết định.
- `Block.stop()`: chặn, giữ route hiện tại; không gọi thêm điều hướng.
- `Block.then(() => router.go(...))`: chặn rồi thực hiện hành động sau đó; chỉ dùng
  khi thực sự cần điều hướng nối tiếp, tránh tạo vòng lặp guard.
- `onExit` trả `true/false` hoặc `Future<bool>`: quyết định có rời route không.
  App dùng Future từ dialog để xác nhận bản nháp.

Tránh đặt network request không kiểm soát trong redirect vì callback có thể được
gọi nhiều lần qua nhiều chu kỳ. Thường đọc auth state đã được tải, và dùng
refreshListenable khi state đổi. Auth trong app này chỉ là giả lập.

`PopScope` thuộc Flutter có thể dùng cho xử lý Back/predictive-back theo từng
widget; không thay hoàn toàn `onExit` cho mọi lệnh `go` thay route. Không ghép hai
guard xác nhận trên cùng màn nếu không cần. `WillPopScope` không phải lựa chọn
phù hợp với Router API. `onExit` cũng không bảo đảm chặn được đóng tab browser;
bản nháp quan trọng cần được lưu độc lập.

## Các kiểu shell

| Thành phần | Dùng khi |
| --- | --- |
| `ShellRoute` | Có khung dùng chung quanh một Navigator con |
| `StatefulShellRoute` | Cần một Navigator riêng cho mỗi nhánh, giữ stack từng nhánh |
| `.indexedStack` | Dùng cách chứa branch có sẵn, giảm UI cần viết |
| `navigatorContainerBuilder` | Tự quản lý cách trình bày/animation giữa các branch |
| `StatefulShellBranch` | Khai báo routes/key/initialLocation/observers/restoration của một nhánh |
| `preload` | Khởi tạo branch sớm thay vì đợi lần chọn đầu tiên |
| `parentNavigatorKey` | Đặt Page của route lên Navigator tổ tiên cụ thể |
| `notifyRootObserver` | Cho event của shell báo tới observer gốc; app tắt để log không trùng |

`builder` của shell nhận child Navigator hoặc StatefulNavigationShell.
`pageBuilder` cho thêm quyền kiểm soát Page chứa toàn shell. Muốn restoration của
shell cần restorationScopeId và pageBuilder với Page.restorationId; StatefulShell
còn cần restorationScopeId của từng branch.

## Page và animation

`builder` trả Widget, router tự tạo Page phù hợp app. `pageBuilder` trả Page do bạn
quản lý: MaterialPage, CupertinoPage, CustomTransitionPage hoặc NoTransitionPage.
Trong pageBuilder dùng `key: state.pageKey` và restorationId khi cần restoration.

`CustomTransitionPage.transitionsBuilder` nhận animation vào/rời trang và
secondaryAnimation của route phía trên. Demo chỉ fade để UI tối giản. Các tùy
chọn `transitionDuration`, `reverseTransitionDuration`, `opaque`, `barrierColor`,
`barrierDismissible`, `maintainState`, `fullscreenDialog` phục vụ cách trình bày
Page. Không cần tự viết một animation phức tạp để học cách routing hoạt động.

Dialog thông thường có thể mở bằng `showDialog`, không cần thêm GoRoute. Muốn một
modal mở được từ URL thì mô hình hóa bằng route và Page phù hợp. Chọn đúng
Navigator khi đóng dialog để không pop nhầm màn bên dưới.

## Các cách xử lý lỗi thay thế nhau

App dùng `errorBuilder` để hiển thị URL và GoException. Có hai lựa chọn thay thế:

```dart
// Thay errorBuilder khi cần tự chọn Page/animation cho màn lỗi.
errorPageBuilder: (context, state) => MaterialPage<void>(
  key: state.pageKey,
  child: ErrorScreen(message: state.error.toString()),
),
```

```dart
// Hoặc tự xử lý lỗi và chuyển về một route an toàn đã được khai báo.
onException: (context, state, router) {
  router.go('/');
},
```

`ErrorScreen` ở snippet đầu là widget tự viết của app sử dụng. Không cấu hình hai
hoặc ba callback lỗi cùng lúc. `errorBuilder` xử lý lỗi routing, không tự bắt mọi
exception trong build widget hoặc lỗi HTTP. “Sản phẩm không tồn tại” nên được xử
lý trong lớp dữ liệu/UI, như ProductScreen của demo.

## Typed routes và các biến thể codegen

`GoRouteData` mô tả màn hình bằng class. `@TypedGoRoute` mô tả path/name/cây con.
`go_router_builder` sinh `.location`, `.go`, `.push<T>`, `.pushReplacement`,
`.replace` và `$appRoutes`. App dùng typed route thật ở mục 10, không mô phỏng
bằng một hàm chỉ ghép String.

Tham số trong path trở thành path parameter; tham số khác trở thành query.
Tham số tên `$extra` là object ngoài URL. Enum/bool/int có thể được chuyển đổi
bởi generator. Giá trị mặc định có thể được bỏ khỏi query. Tính an toàn kiểu áp
dụng cho lời gọi Dart; URL từ web/platform vẫn cần validation.

Các lớp `ShellRouteData`/`TypedShellRoute`,
`StatefulShellRouteData`/`TypedStatefulShellRoute` và
`StatefulShellBranchData`/`TypedStatefulShellBranch` là cách khai báo các shell
tương ứng bằng annotation. `RelativeGoRouteData`/`TypedRelativeGoRoute` phục vụ
route typed tương đối. Chúng dùng cùng cơ chế Navigator/shell đã thực hành trong
app; demo giữ shell viết tay để cây Navigator dễ quan sát, và typed route riêng
để phần codegen có ví dụ ngắn, chạy được.

## Web, deep links và restoration

App giữ hash strategy mặc định (`/#/products/1`). Muốn bỏ `#`, host có thể thêm
`flutter_web_plugins: {sdk: flutter}` rồi gọi `usePathUrlStrategy()` trước runApp.
Server phải rewrite những đường dẫn app về index.html; nếu không, refresh URL
con có thể trả HTTP 404 trước khi Flutter chạy.

`Router.neglect(context, () => context.go(...))` điều chỉnh browser history cho
một lần chuyển; `routerNeglect: true` áp dụng toàn router. Thay URL không có nghĩa
phải tạo thêm history entry. `GoRouter.optionURLReflectsImperativeAPIs` là cấu hình
static cho việc các lệnh imperative có phản ánh trên thanh URL hay không; không
coi nó là giải pháp làm browser history giống hoàn toàn Navigator stack.
Nếu cần link HTML thật để mở tab mới bằng chuột/phím, có thể dùng widget `Link`
của `url_launcher`; đây là package bổ sung, không nằm trong dependency demo.

`StatefulShellRoute` giữ nhánh trong RAM. State restoration phục hồi state đã
serialize sau khi OS hủy app; cần cả cấu hình router và RestorableProperty của
widget. Cả hai đều không thay database cho dữ liệu cần lưu lâu dài. Session giả
lập không được persist: nếu restore vào route cần auth, redirect có thể yêu cầu
đăng nhập lại.

Tham khảo: [API 17.0.1](https://pub.dev/documentation/go_router/17.0.1/),
[Configuration](https://pub.dev/documentation/go_router/17.0.1/topics/Configuration-topic.html),
[Navigation](https://pub.dev/documentation/go_router/17.0.1/topics/Navigation-topic.html),
[builder](https://pub.dev/packages/go_router_builder/versions/4.1.1),
[Flutter Router/deep links](https://docs.flutter.dev/ui/navigation/deep-linking).
