import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_go_route_navigation_bar/package_go_route_navigation_bar.dart';

void main() {
  testWidgets('năm tab chuyển màn hình bằng go_router', (tester) async {
    await tester.pumpWidget(const GoRouteNavigationBarApp());
    await tester.pumpAndSettle();
    expect(find.text('Màn hình Trang chủ'), findsOneWidget);

    for (final entry in <String, String>{
      'Lịch sử': 'Màn hình Lịch sử',
      'Tài sản': 'Màn hình Tài sản',
      'Cá nhân': 'Màn hình Cá nhân',
      'Trang chủ': 'Màn hình Trang chủ',
    }.entries) {
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
    }

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Màn hình Đầu tư'), findsOneWidget);
  });
}
