import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_go_route_base/package_go_route_base.dart';

void main() {
  testWidgets('trang đầu chỉ có hai lựa chọn, chưa có bottom bar', (
    tester,
  ) async {
    await tester.pumpWidget(const GoRouteBaseApp());
    await tester.pumpAndSettle();
    expect(find.byType(TextButton), findsNWidgets(2));
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Xem sản phẩm demo'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('đăng nhập từ trang đầu vào app có bottom bar', (tester) async {
    await tester.pumpWidget(const GoRouteBaseApp());
    await tester.tap(find.text('Đăng nhập'));
    await tester.pumpAndSettle();
    expect(find.text('Ví dụ navigation'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('push nhận kết quả từ pop', (tester) async {
    await tester.pumpWidget(const GoRouteBaseApp());
    await tester.tap(find.text('Đăng nhập'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('push: chọn giá trị'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chọn Flutter'));
    await tester.pumpAndSettle();
    expect(find.text('Kết quả từ push/pop: Flutter'), findsOneWidget);
  });

  testWidgets('sản phẩm demo yêu cầu đăng nhập rồi mở đúng chi tiết', (
    tester,
  ) async {
    await tester.pumpWidget(const GoRouteBaseApp());
    await tester.tap(find.text('Xem sản phẩm demo'));
    await tester.pumpAndSettle();
    expect(find.text('Bạn cần đăng nhập để xem sản phẩm 42.'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.tap(find.widgetWithText(TextButton, 'Đăng nhập'));
    await tester.pumpAndSettle();
    expect(find.text('Sản phẩm 42'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('deep link route con quay lại đúng route cha', (tester) async {
    await tester.pumpWidget(
      const GoRouteBaseApp(initialLocation: '/products/42/reviews'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bạn cần đăng nhập để xem sản phẩm 42.'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Đăng nhập'));
    await tester.pumpAndSettle();
    expect(find.text('Đánh giá sản phẩm 42'), findsOneWidget);
    await tester.tap(find.text('Back về sản phẩm'));
    await tester.pumpAndSettle();
    expect(find.text('Sản phẩm 42'), findsOneWidget);
    expect(find.text('Extra: không có (ví dụ deep link)'), findsOneWidget);
  });

  testWidgets('route được bảo vệ quay về sau đăng nhập', (tester) async {
    await tester.pumpWidget(const GoRouteBaseApp(initialLocation: '/account'));
    await tester.pumpAndSettle();
    expect(find.text('Yêu cầu đăng nhập'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Đăng nhập'));
    await tester.pumpAndSettle();
    expect(find.text('Đã đăng nhập.'), findsOneWidget);
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    expect(find.text('Bắt đầu'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('đổi tab rồi quay lại giữ trang chi tiết', (tester) async {
    await tester.pumpWidget(const GoRouteBaseApp(initialLocation: '/account'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Đăng nhập'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.list));
    await tester.pumpAndSettle();
    await tester.tap(find.text('pushNamed: sản phẩm 42'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.list));
    await tester.pumpAndSettle();
    expect(find.text('Sản phẩm 42'), findsOneWidget);
  });
}
