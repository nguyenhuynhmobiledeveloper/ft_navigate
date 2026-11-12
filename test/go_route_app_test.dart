import 'package:demo_ft_navigate/main.dart' as application;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('entry point chạy package_go_route_base', (tester) async {
    application.main();
    await tester.pumpAndSettle();
    expect(find.text('go_router cơ bản'), findsOneWidget);
    await tester.tap(find.text('go: danh sách sản phẩm'));
    await tester.pumpAndSettle();
    expect(find.text('Query sort: normal'), findsOneWidget);
  });
}
