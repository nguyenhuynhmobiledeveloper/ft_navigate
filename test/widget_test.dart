import 'package:flutter_test/flutter_test.dart';
import 'package:package_navigator_v1/package_navigator_v1.dart';

void main() {
  testWidgets('MaterialPageRoute opens the second page', (tester) async {
    await tester.pumpWidget(const MaterialPageRouteExampleApp());
    await tester.tap(find.text('Nút bấm với GestureDetector'));
    await tester.pumpAndSettle();

    expect(find.text('Đây là màn 2'), findsOneWidget);
  });

  testWidgets('Named route passes its argument', (tester) async {
    await tester.pumpWidget(const PushNamed());
    await tester.tap(find.text('Sang màn 1'));
    await tester.pumpAndSettle();

    expect(find.text('ArgumentRouteContent'), findsOneWidget);
  });

  testWidgets('Global navigator key example opens the second page',
      (tester) async {
    await tester.pumpWidget(const GlobalKeyExampleApp());
    await tester.tap(find.text('Sang màn 1'));
    await tester.pumpAndSettle();

    expect(find.text('argumentRoute'), findsOneWidget);
  });
}
