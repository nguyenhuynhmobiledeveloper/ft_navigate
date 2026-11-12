import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_go_route_base/package_go_route_base.dart';

void main() {
  testWidgets('push nhận kết quả từ pop', (tester) async {
    await tester.pumpWidget(const GoRouteBaseApp());
    await tester.tap(find.text('push: chọn giá trị'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chọn Flutter'));
    await tester.pumpAndSettle();
    expect(find.text('Kết quả từ push/pop: Flutter'), findsOneWidget);
  });

  testWidgets('deep link route con dựng cả route cha', (tester) async {
    await tester.pumpWidget(
      const GoRouteBaseApp(initialLocation: '/products/42/reviews'),
    );
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
    expect(find.text('Đăng nhập'), findsWidgets);
    await tester.tap(find.widgetWithText(TextButton, 'Đăng nhập'));
    await tester.pumpAndSettle();
    expect(find.text('Đã đăng nhập.'), findsOneWidget);
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    expect(find.text('Đăng nhập'), findsWidgets);
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
