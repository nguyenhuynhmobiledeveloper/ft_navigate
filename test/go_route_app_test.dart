import 'package:demo_ft_navigate/main.dart' as application;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('entry point chạy package_go_route', (tester) async {
    application.main();
    await tester.pumpAndSettle();
    expect(find.text('Thực hành go_router'), findsOneWidget);
    await tester.tap(find.text('2. Path, query, name, extra, nested route'));
    await tester.pumpAndSettle();
    expect(find.text('Path, query, named route'), findsOneWidget);
  });
}
