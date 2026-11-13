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
        final path = state.uri.path;
        debugPrint('11111 path: $path');
        debugPrint('11111 session.signedIn: ${session.signedIn}');
        // Nếu trạng thái là chưa đăng nhập mà muốn vào account
        if (!session.signedIn && path == '/account') {
          // Ghi URL đích vào query để đăng nhập xong quay về đúng màn hình.
          // Uri tự mã hóa query, kể cả khi URL đích có dấu ? hoặc &.
          // from lưu lại nơi user muốn đến --> đăng nhập xong thì tới đúng màn đó
          debugPrint('11111 state.uri: ${state.uri.toString()}');

          return Uri(
            path: '/login',
            queryParameters: {'from': state.uri.toString()},
          ).toString();
        }

        if (session.signedIn && path == '/login') {
          final from = state.uri.queryParameters['from'];
          // Query đến từ URL ngoài app: chỉ nhận đường dẫn nội bộ hợp lệ.
          return from != null &&
                  from.startsWith('/') &&
                  !from.startsWith('//') &&
                  Uri.tryParse(from)?.path != '/login'
              ? from
              : '/account';
        }
        // null nghĩa là tiếp tục tới route đang được yêu cầu.
        return null;
      },
      routes: [
        // GoRoute : Định nghĩa 1 đường dẫn và màn hình tương ứng
        GoRoute(
          // path: Đường dẫn URL
          path: '/',
          // name: Tên định danh route
          // Bạn có thể đặt tên cho route để điều hướng thay vì sử dụng URL trực tiếp.
          name: "home",
          // buider: Tạo widget

          builder: (context, state) => const HomeScreen(),
          // pageBuilder : Tạo page tuỳ chỉnh
          // routes: các route con
          // parentNavigatorKey : Chỉ định Navigator cha

          // redirect // Redirect riêng của route
          // onExit : Xử lý khi rời khỏi route
        ),
        // Màn hình pop giá trị về màn trước đó
        GoRoute(path: '/pick', builder: (context, state) => const PickScreen()),
        // Màn hình đăng nhập
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(session: session),
        ),
        // Mỗi branch có Navigator riêng.
        // indexedStack: giữ màn hình đang mở trong tab A khi chuyển qua tab B rồi quay lại.
        // StatefulShellRoute: Cho phép mỗi tab có một Navigator riêng
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => TabsScreen(shell: shell),
          // 2 Nhánh của Bottombar
          branches: [
            // Nhánh sản phẩm
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/products',
                  name: 'products',
                  builder: (context, state) => ProductsScreen(
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
            // StateShellBranch : Thành phần bên trong của StatefulShellRoute
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

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    // App dùng Router API: mọi URL và nút Back đều đi qua GoRouter.
    routerConfig: router,
    debugShowCheckedModeBanner: false,
  );
}
