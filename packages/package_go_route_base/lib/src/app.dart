import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens.dart';
import 'session.dart';

// Hàm chính chạy app lên tương tự hàm main
void runGoRouteBaseApp() => runApp(const GoRouteBaseApp());

/// App giữ router trong State để mỗi lần build không tạo lại cây route và stack.
class GoRouteBaseApp extends StatefulWidget {
  const GoRouteBaseApp({super.key, this.initialLocation = '/'});

  /// Cho phép mở thẳng một URL khi chạy test hoặc thử deep link.
  final String initialLocation;

  @override
  State<GoRouteBaseApp> createState() => _GoRouteBaseAppState();
}

class _GoRouteBaseAppState extends State<GoRouteBaseApp> {
  // Lấy trạng thái là đã đăng nhập chưa để hiển thị route màn hình nào
  final session = DemoSession();

  // Biến định nghĩa GoRouter của toàn app
  late final GoRouter router;

  // Vòng đời khởi tạo của widget
  @override
  void initState() {
    super.initState();
    // Khai báo giá trị của GoRouter
    router = GoRouter(
      // Xác định route khởi tạo. Nếu không bị chi phối bởi platform location hoặc cấu hình khác.
      initialLocation: widget.initialLocation,
      // Có thể theo dõi qúa trình match route và navigation trên console
      debugLogDiagnostics: true,
      // Khi session đổi, router chạy lại redirect ngay cả khi URL không đổi.
      // Biến kích hoạt chạy lại hàm redirect : khi nó thay đổi hàm redirect chạy lại để điều hướng
      refreshListenable: session,
      // Hàm quyết định có chuyển sang URL khác trước khi hiển thị route được yêu cầu hay không
      redirect: (context, state) {
        // path : đường dẫn mà user đang muốn tới
        // redirect có thể được trigger khi refreshListenable thay đổi
        // Nên giá trị của path có thể là path mà user đang hướng tới - hoặc giá trị path màn hình mà đang đứng ở thời điểm hiện tại
        final path = state.uri.path;
        debugPrint('redirect state: ${state.toString()}');
        debugPrint('redirect state.uri: ${state.uri}');
        debugPrint('redirect session.signedIn: ${session.signedIn}');

        // Khi ấn đăng nhập ở màn hình vào xem sản phầm nhưng yêu cầu đăng nhập -- Đăng nhập xong sẽ tới đúng màn sản phẩm đó
        // flutter: path: /products/42  -- Điều hướng tới màn hình sản phẩm nhưng chưa đăng nhập
        // flutter: session.signedIn: false
        // flutter: state.uri: /products/42
        if (!session.signedIn && path != '/' && path != '/login') {
          // Ghi URL đích vào query để đăng nhập xong quay về đúng màn hình.
          // Uri tự mã hóa query, kể cả khi URL đích có dấu ? hoặc &.
          // from lưu lại nơi user muốn đến --> đăng nhập xong thì tới đúng màn đó
          debugPrint('Chưa login path: $path');
          debugPrint('Chưa login session.signedIn: ${session.signedIn}');
          debugPrint('Chưa login state.uri: ${state.uri.toString()}');
          debugPrint(
            'Chưa login giá trị return : ${Uri(path: '/login', queryParameters: {'from': state.uri.toString()}).toString()}', // /login?from=/products/42
          );

          // state.uri: /products/42  // Đăng nhập xong sẽ vào đúng trang này
          //  redirect sẽ tự động điều hướng tới màn hình login - và có queryParameters cho nó
          return Uri(
            path: '/login',
            queryParameters: {'from': state.uri.toString()},
          ).toString();
        }

        // Khi bấm nút đăng nhập ở màn hình đăng nhập chỉ thay đổi signedIn làm redirect bị trigger lại
        // URL hiện tại vẫn là /login và tham số queryParameters đã được chỉ định ở trên
        if (session.signedIn && path == '/login') {
          debugPrint('Đã login path: $path');
          debugPrint('Đã login  session.signedIn: ${session.signedIn}');
          final from = state.uri.queryParameters['from'];
          debugPrint(
            'Đã login  state.uri.queryParameters: ${state.uri.queryParameters}',
          );
          debugPrint('Đã login  from: $from');
          // Query đến từ URL ngoài app: chỉ nhận đường dẫn nội bộ hợp lệ.
          return from != null &&
                  from.startsWith('/') &&
                  !from.startsWith('//') &&
                  Uri.tryParse(from)?.path != '/login' &&
                  Uri.tryParse(from)?.path != '/'
              ? from // /products/42
              : '/homeScreen';
        }

        // Khi state global báo đã đăng nhập rồi - và path đang đứng ở màn LandingScreen / thì vào màn ví dụ
        if (session.signedIn && path == '/') return '/homeScreen';
        // null nghĩa là tiếp tục tới route đang được yêu cầu.
        return null;
      },
      routes: [
        // GoRoute : Định nghĩa 1 đường dẫn và màn hình tương ứng
        // Màn hình LandingScreen : chưa đăng nhập
        GoRoute(
          // path: Đường dẫn URL
          path: '/',
          // name: Tên định danh route
          // Bạn có thể đặt tên cho route để điều hướng thay vì sử dụng URL trực tiếp.
          name: "landingScreen",
          // buider: Tạo widget

          builder: (context, state) => LandingScreen(session: session),
          // pageBuilder : Tạo page tuỳ chỉnh
          // routes: các route con
          // parentNavigatorKey : Chỉ định Navigator cha

          // redirect // Redirect riêng của route
          // onExit : Xử lý khi rời khỏi route
        ),
        // Màn hình đăng nhập
        GoRoute(
          path: '/login',
          // widget màn hình LoginScreen nhận 2 props: session, và from (để chỉ định đúng màn hình sẽ tới khi đăng nhập thành công)
          builder: (context, state) => LoginScreen(
            session: session,
            from: state.uri.queryParameters['from'],
          ),
        ),

        // indexedStack: giữ màn hình đang mở trong tab A khi chuyển qua tab B rồi quay lại.
        // StatefulShellRoute: Cho phép mỗi tab có một Navigator riêng
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => TabsScreen(shell: shell),
          // StatefulShellRoute : Đang chứa 3 BottomTabBar - Mỗi branch có Navigator riêng.
          // 3 nhánh của bottom bar: ví dụ, sản phẩm, tài khoản.
          branches: [
            // Nhánh bottombar - ví dụ - có 1 màn hình con bên trong
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/homeScreen',
                  builder: (context, state) =>
                      // state chính là GoRouterState : Object chứa thông tin của route hiện tại
                      // state.uri : URI hiện tại
                      // state.pathParameters :	Các tham số nằm trong path - sử dụng khi dữ liệu nằm trong đường dẫn url
                      // state.uri.queryParameters : Các tham số nằm trong query
                      // state.extra : Dữ liệu truyền thêm
                      // extra dùng để truyền một object bất kỳ đi kèm navigation.
                      // state.matchedLocation : Đường dẫn được match
                      // state.fullPath : Pattern của route được match
                      // state.name : Tên route
                      // state.pageKey : Key của Page
                      // state.error : Thông tin lỗi nếu có
                      const HomeScreen(),
                  routes: [
                    // Màn chọn giá trị nằm trong Navigator của tab homeScreen.
                    GoRoute(
                      path: 'pick',
                      builder: (context, state) => const PickScreen(),
                    ),
                  ],
                ),
              ],
            ),
            // Nhánh sản phẩm
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/products',
                  name: 'products',
                  builder: (context, state) => ProductsScreen(
                    // Query parameters là phần nằm sau dấu ? trong URL
                    sort: state.uri.queryParameters['sort'] ?? 'normal',
                  ),
                  routes: [
                    // Path con không có / đầu. URL đầy đủ là /products/:id.
                    GoRoute(
                      path: ':id',
                      name: 'product',
                      builder: (context, state) => ProductScreen(
                        // Lấy data từ đường dẫn url ra
                        id: state.pathParameters['id']!,
                        // extra truyền object trong bộ nhớ, không nằm trong URL.
                        // Deep link hoặc reload có thể không có extra.
                        note: state.extra is String
                            ? state.extra as String
                            : null,
                      ),
                      // Màn hình review là nhánh con của product
                      routes: [
                        GoRoute(
                          path: 'reviews',
                          name: 'reviews',
                          builder: (context, state) =>
                              ReviewsScreen(id: state.pathParameters['id']!),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            //  Nhánh tài khoản
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/account',
                  builder: (context, state) => AccountScreen(session: session),
                ),
              ],
            ),
          ],
        ),
      ],
      // URL không khớp route nào sẽ tới đây thay vì màn lỗi mặc định.
      errorBuilder: (context, state) => ErrorScreen(message: '${state.error}'),
    );
  }

  @override
  void dispose() {
    router.dispose();
    session.dispose();
    super.dispose();
  }

  // Vòng đời build chính - widget này chỉ điều phối sẽ hiển thị màn hình nào thôi chứ nó không có giao diện chính thức
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    // App dùng Router API: mọi URL và nút Back đều đi qua GoRouter.
    routerConfig: router,
    debugShowCheckedModeBanner: false,
  );
}
