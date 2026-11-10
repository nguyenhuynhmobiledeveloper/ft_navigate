import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../demo_state.dart';
import '../screens/advanced_screens.dart';
import '../screens/auth_screens.dart';
import '../screens/catalog_screens.dart';
import '../screens/guard_screens.dart';
import '../screens/home_screen.dart';
import '../screens/shell_screens.dart';
import '../screens/stack_screens.dart';
import 'extra_codec.dart';
import 'navigation_observer.dart';
import 'route_names.dart';
import 'typed_routes.dart';

/// Chỉ chấp nhận URL nội bộ làm đích sau đăng nhập. Tham số `from` có thể đến từ
/// deep link bên ngoài: không tin rằng nó luôn do chính ứng dụng sinh ra.
String safeReturnLocation(String? raw) {
  final uri = raw == null ? null : Uri.tryParse(raw);
  if (uri == null ||
      uri.hasScheme ||
      uri.hasAuthority ||
      !uri.path.startsWith('/') ||
      uri.path.startsWith('//') ||
      uri.path == '/login' ||
      uri.path.startsWith('/login/')) {
    return '/account';
  }
  return uri.toString();
}

String _loginLocation(Uri destination) {
  // Platform có thể gửi goroutedemo://demo/account?...; router nội bộ chỉ cần
  // path/query/fragment. Không đưa scheme/host của deep link vào return URL.
  final internalUri = Uri(
    path: destination.path,
    query: destination.hasQuery ? destination.query : null,
    fragment: destination.hasFragment ? destination.fragment : null,
  );
  return Uri(
    path: '/login',
    queryParameters: {'from': internalUri.toString()},
  ).toString();
}

/// Tâm điểm bài học: một object giữ router, navigator keys và state mà router
/// quan tâm. App tạo object này MỘT LẦN trong initState và dispose khi kết thúc.
/// Tạo GoRouter/GlobalKey trong build dễ làm mất stack, tab state và listener.
class DemoNavigation {
  DemoNavigation({
    String initialLocation = '/',
    bool diagnostics = kDebugMode,
  }) {
    // Giữ các RouteBase không đổi khi bật/tắt feature để các shell vẫn có cùng
    // navigatorKey và cấu hình cơ bản. Chỉ route experimental được thêm/bớt.
    _baseRoutes = _createRoutes();
    _configuration = ValueNotifier(_buildConfiguration());

    // Nếu bảng route luôn cố định, dùng GoRouter(routes: [...]) là đủ.
    // routingConfig cho phép thay cả cây route qua ValueListenable mà không
    // tạo một GoRouter mới. Router tự match lại location hiện tại khi config đổi.
    router = GoRouter.routingConfig(
      routingConfig: _configuration,
      navigatorKey: rootKey,
      initialLocation: initialLocation,
      // Không overridePlatformDefaultLocation: platform deep link được ưu tiên
      // khi có. initialLocation chỉ là nơi bắt đầu khi không có deep link.
      refreshListenable: session,
      extraCodec: const DemoExtraCodec(),
      debugLogDiagnostics: diagnostics,
      restorationScopeId: 'demo-router',
      observers: [DemoNavigatorObserver('ROOT', journal)],
      // builder trả Widget; router tự bọc thành Page. Nếu cần kiểm soát Page lỗi,
      // chọn errorPageBuilder. onException là lựa chọn xử lý lỗi bằng callback.
      // Chỉ cấu hình MỘT trong ba, không đặt chúng cùng lúc.
      errorBuilder: (context, state) => RouteErrorScreen(state: state),
    );
  }

  final session = DemoSession();
  final draft = DemoDraft();
  final journal = NavigationJournal();

  // root: toàn app. workspace: một Navigator con. feed/saved: mỗi tab một stack.
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'go-route-root');
  final workspaceKey = GlobalKey<NavigatorState>(debugLabel: 'workspace');
  final feedKey = GlobalKey<NavigatorState>(debugLabel: 'feed');
  final savedKey = GlobalKey<NavigatorState>(debugLabel: 'saved');

  late final GoRouter router;
  late final List<RouteBase> _baseRoutes;
  late final ValueNotifier<RoutingConfig> _configuration;
  bool experimentalEnabled = false;
  bool entryAllowed = false;

  void setExperimental(bool enabled) {
    experimentalEnabled = enabled;
    _configuration.value = _buildConfiguration();
  }

  RoutingConfig _buildConfiguration() => RoutingConfig(
    routes: [
      ..._baseRoutes,
      if (experimentalEnabled)
        GoRoute(
          path: '/experimental',
          builder: (_, __) => const InfoScreen(
            title: 'Route động đang hoạt động',
            message: 'Route này chỉ tồn tại khi bật tính năng ở /advanced.',
          ),
        ),
    ],
    // Thứ tự vào route: onEnter → redirect cấp router → redirect của GoRoute.
    // onEnter nhận cả current và next. Block.stop giữ location hiện tại;
    // Allow cho tiếp tục. Cả callback này và redirect đều có thể async.
    onEnter: (context, current, next, router) {
      if (next.uri.path == '/guarded' && !entryAllowed) {
        journal.record('onEnter BLOCK ${next.uri}: hãy bật công tắc');
        return const Block.stop();
      }
      // Có thể dùng Allow(then: ...) hoặc Block.then(...) cho hành động sau
      // quyết định. Không gọi router.go trực tiếp để điều hướng lồng trong guard.
      return const Allow();
    },
    redirect: _redirect,
    // Ngăn redirect vòng lặp vô hạn. /loop-a ↔ /loop-b là ví dụ cố ý gây lỗi.
    redirectLimit: 5,
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    // Trong phiên bản này, top-level redirect chỉ chạy một lần mỗi chu kỳ.
    // Vì vậy phải kiểm tra luôn URI đích sau login, không giả định router sẽ
    // gọi lại callback này cho URL vừa trả về.
    final target = session.signedIn && state.uri.path == '/login'
        ? Uri.parse(safeReturnLocation(state.uri.queryParameters['from']))
        : state.uri;
    final path = target.path;
    final protected = path == '/account' || path == '/admin';
    if (protected && !session.signedIn) {
      // Giữ TOÀN BỘ URI, gồm query/fragment, để quay lại đúng đích sau login.
      // Uri tự encode `from`, tránh làm vỡ URL nếu đích cũng chứa dấu ? và &.
      return _loginLocation(target);
    }

    // Typed routes bảo vệ lời gọi Dart nhưng không ngăn người dùng nhập URL sai.
    // Kiểm tra chuỗi trước khi factory generated dùng int.parse cho tham số int.
    if (path.startsWith('/typed-book/')) {
      final bookId = int.tryParse(target.pathSegments.last);
      final page = int.tryParse(target.queryParameters['page'] ?? '1');
      if (bookId == null || bookId < 1 || page == null || page < 1) {
        return '/bad-link';
      }
    }
    // null = không redirect, cho router tiếp tục. Không gọi go() trong redirect.
    return target == state.uri ? null : target.toString();
  }

  List<RouteBase> _createRoutes() => [
    GoRoute(
      path: '/',
      name: RouteNames.home,
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/stack',
      builder: (_, __) => const StackScreen(),
      routes: [
        // Route con viết path tương đối. URL đầy đủ: /stack/step/:step.
        GoRoute(
          path: 'step/:step',
          builder: (_, state) =>
              StackStepScreen(step: state.pathParameters['step']!),
        ),
      ],
    ),
    GoRoute(path: '/pick', builder: (_, __) => const PickerScreen()),
    GoRoute(
      path: '/products',
      name: RouteNames.products,
      builder: (_, __) => const ProductsScreen(),
      routes: [
        GoRoute(
          path: ':id',
          name: RouteNames.product,
          builder: (_, state) => ProductScreen(
            id: state.pathParameters['id']!,
            preview: state.extra is ProductPreview
                ? state.extra as ProductPreview
                : null,
          ),
          routes: [
            // Khi mở /products/1/reviews từ deep link, cả ba Page được tạo:
            // ProductsScreen → ProductScreen → ReviewsScreen.
            GoRoute(
              path: 'reviews',
              name: RouteNames.reviews,
              builder: (_, state) =>
                  ReviewsScreen(id: state.pathParameters['id']!),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      name: RouteNames.login,
      builder: (_, state) => LoginScreen(
        session: session,
        from: state.uri.queryParameters['from'],
      ),
    ),
    GoRoute(
      path: '/account',
      name: RouteNames.account,
      builder: (_, __) => AccountScreen(session: session),
    ),
    GoRoute(
      path: '/admin',
      // Kiểm tra quyền ở route đích, kể cả khi vừa redirect từ /login.
      // Route-level redirect chạy sau top-level redirect.
      redirect: (_, state) {
        if (!session.signedIn) {
          return _loginLocation(state.uri);
        }
        return session.isAdmin ? null : '/forbidden';
      },
      builder: (_, __) => const InfoScreen(
        title: 'Quản trị',
        message: 'Chỉ session có quyền admin được tới route này.',
      ),
    ),
    GoRoute(
      path: '/forbidden',
      builder: (_, __) => const InfoScreen(
        title: 'Không có quyền',
        message: 'Về /account, đăng xuất rồi đăng nhập admin để thử lại.',
      ),
    ),
    GoRoute(
      path: '/bad-link',
      builder: (_, __) => const InfoScreen(
        title: 'Tham số URL không hợp lệ',
        message: 'bookId và page phải là số nguyên dương.',
      ),
    ),
    GoRoute(
      path: '/editor',
      builder: (_, __) => EditorScreen(draft: draft),
      onExit: (context, state) => confirmExit(context, draft),
    ),
    // Redirect riêng của route: dùng cho URL cũ, alias hoặc đường dẫn mặc định.
    GoRoute(path: '/legacy', redirect: (_, __) => '/products/1?source=legacy'),
    GoRoute(path: '/loop-a', redirect: (_, __) => '/loop-b'),
    GoRoute(path: '/loop-b', redirect: (_, __) => '/loop-a'),
    GoRoute(
      path: '/guarded',
      builder: (_, __) => const InfoScreen(
        title: 'onEnter đã cho phép',
        message: 'Công tắc ở /advanced quyết định Allow hay Block.',
      ),
    ),
    GoRoute(
      path: '/transition',
      // pageBuilder trả Page để kiểm soát transition, key, restorationId...
      // Không đặt builder cùng pageBuilder cho một route.
      pageBuilder: (_, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        name: 'custom-transition',
        restorationId: state.pageKey.value,
        transitionDuration: const Duration(milliseconds: 250),
        child: const InfoScreen(
          title: 'CustomTransitionPage',
          message: 'Page này dùng FadeTransition khi push/pop.',
        ),
        transitionsBuilder: (_, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: '/no-transition',
      pageBuilder: (_, state) => NoTransitionPage<void>(
        key: state.pageKey,
        restorationId: state.pageKey.value,
        child: const InfoScreen(
          title: 'NoTransitionPage',
          message: 'Đổi trang không có animation.',
        ),
      ),
    ),
    GoRoute(
      path: '/cupertino',
      pageBuilder: (_, state) => CupertinoPage<void>(
        key: state.pageKey,
        restorationId: state.pageKey.value,
        fullscreenDialog: true,
        child: const InfoScreen(
          title: 'CupertinoPage',
          message:
              'Page kiểu Cupertino; fullscreenDialog thay kiểu trình bày/chuyển cảnh.',
        ),
      ),
    ),
    GoRoute(path: '/restore', builder: (_, __) => const RestorationScreen()),
    GoRoute(
      path: '/inspect',
      builder: (_, __) => InspectScreen(journal: journal),
    ),
    GoRoute(
      path: '/advanced',
      builder: (_, __) => AdvancedScreen(
        journal: journal,
        experimentalEnabled: () => experimentalEnabled,
        setExperimental: setExperimental,
        entryAllowed: () => entryAllowed,
        setEntryAllowed: (value) => entryAllowed = value,
        // Service/view-model có thể được inject GoRouter và gọi trực tiếp.
        // Không cần lưu BuildContext lâu dài, không cần singleton global.
        navigateWithoutContext: () => router.go('/inspect'),
      ),
    ),
    ShellRoute(
      navigatorKey: workspaceKey,
      restorationScopeId: 'workspace-navigator',
      observers: [DemoNavigatorObserver('WORKSPACE', journal)],
      // Từ go_router 17, shell cũng có thể báo event cho root observer.
      // Tắt ở đây để nhật ký phân biệt rõ event của từng Navigator.
      notifyRootObserver: false,
      pageBuilder: (_, state, child) => MaterialPage<void>(
        key: state.pageKey,
        name: 'workspace-shell',
        restorationId: 'workspace-shell-page',
        child: WorkspaceShell(child: child),
      ),
      routes: [
        GoRoute(
          path: '/workspace',
          builder: (_, __) => const WorkspaceScreen(),
          routes: [
            GoRoute(
              path: 'settings',
              builder: (_, __) => const WorkspaceScreen(settings: true),
            ),
            GoRoute(
              path: 'full-screen',
              // Key này phải là key của một Navigator tổ tiên của route.
              parentNavigatorKey: rootKey,
              builder: (_, __) => const InfoScreen(
                title: 'Trang trên root Navigator',
                message: 'Thanh ShellRoute bị che. Back sẽ mở lại workspace.',
              ),
            ),
          ],
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      restorationScopeId: 'tabs-navigator',
      notifyRootObserver: false,
      pageBuilder: (_, state, navigationShell) => MaterialPage<void>(
        key: state.pageKey,
        name: 'tabs-shell',
        restorationId: 'tabs-shell-page',
        child: TabsShell(navigationShell: navigationShell),
      ),
      branches: [
        for (final branch in ['feed', 'saved'])
          StatefulShellBranch(
            navigatorKey: branch == 'feed' ? feedKey : savedKey,
            initialLocation: '/tabs/$branch',
            restorationScopeId: '$branch-navigator',
            // preload khởi tạo branch sớm; mặc định false để chỉ tạo khi dùng.
            // Đây không phải tải dữ liệu server; chỉ tác động vòng đời branch.
            preload: branch == 'saved',
            observers: [DemoNavigatorObserver(branch.toUpperCase(), journal)],
            routes: [
              GoRoute(
                path: '/tabs/$branch',
                builder: (_, __) => BranchScreen(branch: branch),
                routes: [
                  GoRoute(
                    path: 'item/:id',
                    builder: (_, state) => InfoScreen(
                      title: 'Chi tiết $branch ${state.pathParameters['id']}',
                      message:
                          'Đổi tab rồi quay lại: route chi tiết này vẫn ở trên stack của tab.',
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    ),
    // Trộn route viết tay và route generated trong cùng một GoRouter.
    // $appRoutes được sinh từ @TypedGoRoute trong typed_routes.dart.
    ...$appRoutes,
  ];

  void dispose() {
    router.dispose();
    _configuration.dispose();
    session.dispose();
    journal.dispose();
  }
}
