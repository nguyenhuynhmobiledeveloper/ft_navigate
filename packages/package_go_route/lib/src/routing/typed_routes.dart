import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/study_page.dart';

// File .g.dart là code do go_router_builder sinh; không sửa bằng tay.
// Chạy từ thư mục package: dart run build_runner build --delete-conflicting-outputs
part 'typed_routes.g.dart';

/// bookId có trong path nên là path parameter; page không có trong path nên là
/// query parameter. Với default=1, generator có thể bỏ ?page=1 khỏi URL.
/// Lời gọi TypedBookRoute(bookId: 42, page: 2).go(context) được Dart kiểm tra kiểu.
/// Sai tên/thiếu tham số hoặc truyền String thay int bị bắt trước khi chạy app.
/// URL nhập từ bên ngoài vẫn cần kiểm tra: xem DemoNavigation._redirect.
@TypedGoRoute<TypedBookRoute>(path: '/typed-book/:bookId', name: 'typed-book')
class TypedBookRoute extends GoRouteData with $TypedBookRoute {
  const TypedBookRoute({required this.bookId, this.page = 1});
  final int bookId;
  final int page;

  @override
  Widget build(BuildContext context, GoRouterState state) => StudyPage(
    title: 'Typed route: sách $bookId',
    children: [
      Text('Trang: $page'),
      DemoAction('Trang tiếp theo bằng typed route', () {
        TypedBookRoute(bookId: bookId, page: page + 1).go(context);
      }),
      Text('URL từ getter location: $location'),
      const RouteSnapshot(),
    ],
  );
}
