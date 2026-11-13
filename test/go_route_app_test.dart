import 'package:demo_ft_navigate/main.dart' as application;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('entry point chạy package_go_route_navigation_bar', (
    tester,
  ) async {
    application.main();
    await tester.pumpAndSettle();
    expect(find.text('Màn hình Trang chủ'), findsOneWidget);
    await tester.tap(find.text('Lịch sử'));
    await tester.pumpAndSettle();
    expect(find.text('Màn hình Lịch sử'), findsOneWidget);
  });
}
