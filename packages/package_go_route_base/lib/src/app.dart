import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens.dart';
import 'session.dart';

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
  final session = DemoSession();
  late final GoRouter router;

  @override
  void initState() {
    super.initState();
    router = GoRouter(
      initialLocation: widget.initialLocation,
      // Khi session đổi, router chạy lại redirect ngay cả khi URL không đổi.
      refreshListenable: session,
      redirect: (context, state) {
        final path = state.uri.path;
        if (!session.signedIn && path == '/account') {
          // Ghi URL đích vào query để đăng nhập xong quay về đúng màn hình.
          // Uri tự mã hóa query, kể cả khi URL đích có dấu ? hoặc &.
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
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/pick', builder: (context, state) => const PickScreen()),
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(session: session),
        ),
        // Mỗi branch có Navigator riêng. indexedStack giữ màn hình đang mở
        // trong tab A khi chuyển qua tab B rồi quay lại.
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => TabsScreen(shell: shell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/products',
                  name: 'products',
                  builder: (context, state) => ProductsScreen(
                    sort: state.uri.queryParameters['sort'] ?? 'normal',
                  ),
                  routes: [
                    // Path con không có / đầu. URL đầy đủ là /products/:id.
                    GoRoute(
                      path: ':id',
                      name: 'product',
                      builder: (context, state) => ProductScreen(
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
