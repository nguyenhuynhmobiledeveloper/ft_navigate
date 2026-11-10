import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_go_route/package_go_route.dart';

Future<DemoNavigation> startApp(
  WidgetTester tester, [
  String location = '/',
]) async {
  final navigation = DemoNavigation(
    initialLocation: location,
    diagnostics: false,
  );
  await tester.pumpWidget(PackageGoRouteApp(navigation: navigation));
  await tester.pumpAndSettle();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    navigation.dispose();
  });
  return navigation;
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('deep link tạo đủ stack cha/con để Back', (tester) async {
    final app = await startApp(tester, '/products/2/reviews?page=2');
    expect(find.text('Reviews sản phẩm 2'), findsOneWidget);
    app.router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Chi tiết sản phẩm 2'), findsOneWidget);
    app.router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Path, query, named route'), findsOneWidget);
  });

  testWidgets('query được encode và named/relative route hoạt động', (
    tester,
  ) async {
    final app = await startApp(tester, '/products');
    await tapText(tester, 'Đổi query sort');
    expect(app.router.state.uri.queryParameters['q'], 'học Flutter');
    expect(find.text('Thứ tự: desc'), findsOneWidget);
    await tapText(tester, 'Sản phẩm 1: Sách Flutter');
    expect(app.router.state.uri.path, '/products/1');
    await tapText(tester, 'Mở reviews bằng đường dẫn tương đối');
    expect(find.text('Reviews sản phẩm 1'), findsOneWidget);
  });

  testWidgets('extra có thể vắng khi mở URL, id lạ không crash', (
    tester,
  ) async {
    final app = await startApp(tester, '/products/1');
    expect(find.text('Sách Flutter'), findsOneWidget);
    app.router.go('/products/1', extra: const ProductPreview('1', 'Preview'));
    await tester.pumpAndSettle();
    expect(find.text('Preview'), findsOneWidget);
    app.router.go('/products/999');
    await tester.pumpAndSettle();
    expect(find.text('Không có sản phẩm'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('push nhận kết quả từ pop', (tester) async {
    await startApp(tester, '/stack');
    await tapText(tester, 'push trang chọn và chờ kết quả');
    await tapText(tester, 'Chọn Flutter');
    expect(find.text('Kết quả: Flutter'), findsOneWidget);
  });

  testWidgets('replace giữ State, pushReplacement tạo State mới', (
    tester,
  ) async {
    await startApp(tester, '/stack');
    await tapText(tester, 'push bước 1');
    await tapText(tester, 'Tăng bộ đếm bước');
    await tapText(tester, 'replace sang bước 2');
    expect(find.text('Bước 2'), findsOneWidget);
    expect(find.text('Bộ đếm của State: 1'), findsOneWidget);
    await tapText(tester, 'pushReplacement sang bước 3');
    expect(find.text('Bộ đếm của State: 0'), findsOneWidget);
  });

  testWidgets('login giữ deep link và query, logout kích hoạt redirect', (
    tester,
  ) async {
    final app = await startApp(tester, '/account?source=deep-link');
    expect(find.text('Đăng nhập giả lập'), findsOneWidget);
    await tapText(tester, 'Đăng nhập user');
    expect(find.text('Tài khoản'), findsOneWidget);
    expect(app.router.state.uri.queryParameters['source'], 'deep-link');
    await tapText(tester, 'Đăng xuất');
    expect(find.text('Đăng nhập giả lập'), findsOneWidget);
  });

  testWidgets('route quản trị kiểm tra quyền sau đăng nhập', (tester) async {
    final app = await startApp(tester, '/admin');
    await tapText(tester, 'Đăng nhập user');
    expect(
      find.text('Không có quyền'),
      findsOneWidget,
      reason: '${app.router.state.uri} / ${app.router.state.error}',
    );
    app.session.signOut();
    app.router.go('/admin');
    await tester.pumpAndSettle();
    await tapText(tester, 'Đăng nhập admin');
    expect(find.text('Quản trị'), findsOneWidget);
  });

  testWidgets(
    'platform deep link giữ query qua login và nhận URL mới khi app đang mở',
    (tester) async {
      final app = await startApp(
        tester,
        'goroutedemo://demo/account?source=mobile',
      );
      await tapText(tester, 'Đăng nhập user');
      expect(app.router.state.uri.queryParameters['source'], 'mobile');
      // Giả lập thông báo mà WidgetsBinding chuyển cho RouteInformationProvider.
      await app.router.routeInformationProvider.didPushRouteInformation(
        RouteInformation(
          uri: Uri.parse('goroutedemo://demo/products/2/reviews'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Reviews sản phẩm 2'), findsOneWidget);
    },
  );

  testWidgets('onExit giữ hoặc bỏ bản nháp theo xác nhận', (tester) async {
    final app = await startApp(tester, '/editor');
    await tester.enterText(find.byType(TextFormField), 'Chưa lưu');
    app.router.go('/');
    await tester.pumpAndSettle();
    await tapText(tester, 'Ở lại');
    expect(find.text('onExit: bản nháp'), findsOneWidget);
    expect(app.draft.dirty, isTrue);
    app.router.go('/');
    await tester.pumpAndSettle();
    await tapText(tester, 'Rời đi');
    expect(find.text('Thực hành go_router'), findsOneWidget);
    expect(app.draft.dirty, isFalse);
  });

  testWidgets('Back hệ thống cũng đi qua onExit', (tester) async {
    final app = await startApp(tester);
    app.router.push('/editor');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Draft');
    final back = tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tapText(tester, 'Ở lại');
    await back;
    expect(find.text('onExit: bản nháp'), findsOneWidget);
  });

  testWidgets('parentNavigatorKey phủ shell rồi Back trả lại shell', (
    tester,
  ) async {
    final app = await startApp(tester, '/workspace');
    expect(find.text('ShellRoute đang hiện'), findsOneWidget);
    await tapText(tester, 'Mở trang phủ toàn bộ shell');
    expect(find.text('Trang trên root Navigator'), findsOneWidget);
    expect(find.text('ShellRoute đang hiện'), findsNothing);
    app.router.pop();
    await tester.pumpAndSettle();
    expect(find.text('ShellRoute đang hiện'), findsOneWidget);
  });

  testWidgets('tab giữ stack và State, chọn lại tab trở về gốc', (
    tester,
  ) async {
    await startApp(tester, '/tabs/feed');
    await tapText(tester, 'Tăng bộ đếm tab');
    await tapText(tester, 'Mở chi tiết trong tab');
    await tapText(tester, 'Đã lưu');
    expect(find.text('Tab saved'), findsOneWidget);
    await tapText(tester, 'Bảng tin');
    expect(find.text('Chi tiết feed 7'), findsOneWidget);
    await tapText(tester, 'Bảng tin');
    expect(find.text('Bộ đếm feed: 1'), findsOneWidget);
  });

  testWidgets('onEnter Block và Allow', (tester) async {
    final app = await startApp(tester, '/advanced');
    app.router.go('/guarded');
    await tester.pumpAndSettle();
    expect(find.text('Guard, route động, lỗi'), findsOneWidget);
    app.entryAllowed = true;
    app.router.go('/guarded');
    await tester.pumpAndSettle();
    expect(find.text('onEnter đã cho phép'), findsOneWidget);
  });

  testWidgets('cập nhật RoutingConfig match lại URL hiện tại', (tester) async {
    final app = await startApp(tester, '/experimental');
    expect(find.text('Không mở được route'), findsOneWidget);
    app.setExperimental(true);
    await tester.pumpAndSettle();
    expect(find.text('Route động đang hoạt động'), findsOneWidget);
  });

  testWidgets('unknown URL và vòng lặp redirect có trang lỗi', (tester) async {
    final app = await startApp(tester, '/khong-co');
    expect(find.text('Không mở được route'), findsOneWidget);
    app.router.go('/loop-a');
    await tester.pumpAndSettle();
    expect(find.text('Không mở được route'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('typed route và URL nhập sai kiểu', (tester) async {
    final app = await startApp(
      tester,
      const TypedBookRoute(bookId: 42, page: 2).location,
    );
    expect(find.text('Typed route: sách 42'), findsOneWidget);
    await tapText(tester, 'Trang tiếp theo bằng typed route');
    expect(find.text('Trang: 3'), findsOneWidget);
    app.router.go('/typed-book/abc?page=wrong');
    await tester.pumpAndSettle();
    expect(find.text('Tham số URL không hợp lệ'), findsOneWidget);
  });

  testWidgets('custom, no-transition và Cupertino Page mở/đóng được', (
    tester,
  ) async {
    final app = await startApp(tester);
    for (final location in ['/transition', '/no-transition', '/cupertino']) {
      app.router.push(location);
      await tester.pumpAndSettle();
      expect(app.router.canPop(), isTrue);
      app.router.pop();
      await tester.pumpAndSettle();
      expect(find.text('Thực hành go_router'), findsOneWidget);
    }
  });

  testWidgets('restoration phục hồi location và RestorableInt', (tester) async {
    await tester.pumpWidget(const PackageGoRouteApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('11. State restoration'), 300);
    await tapText(tester, '11. State restoration');
    await tapText(tester, 'Tăng giá trị khôi phục');
    await tester.restartAndRestore();
    await tester.pumpAndSettle();
    expect(find.text('State restoration'), findsOneWidget);
    expect(find.text('Giá trị khôi phục: 1'), findsOneWidget);
  });

  test('extra codec đi qua JSON và khôi phục object', () {
    const codec = DemoExtraCodec();
    final restored =
        codec.decode(
              jsonDecode(
                jsonEncode(codec.encode(const ProductPreview('1', 'Sách'))),
              ),
            )
            as ProductPreview;
    expect(restored.id, '1');
    expect(restored.title, 'Sách');
    expect(codec.decode(codec.encode(null)), isNull);
  });

  test(
    'return URL giữ query nhưng từ chối URL ngoài app và vòng lặp login',
    () {
      expect(
        safeReturnLocation('/account?source=link'),
        '/account?source=link',
      );
      for (final value in [
        null,
        '',
        'https://example.com',
        '//example.com',
        '/login?from=/login',
      ]) {
        expect(safeReturnLocation(value), '/account');
      }
    },
  );
}
