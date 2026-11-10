import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/extra_codec.dart';
import '../routing/route_names.dart';
import '../widgets/study_page.dart';

const demoProducts = {'1': 'Sách Flutter', '2': 'Sách Dart'};

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final sort = state.uri.queryParameters['sort'] ?? 'asc';
    final ids = demoProducts.keys.toList()..sort();
    final sortedIds = sort == 'desc' ? ids.reversed : ids;
    return StudyPage(
      title: 'Path, query, named route',
      children: [
        Text('Thứ tự: $sort'),
        DemoAction('Đổi query sort', () {
          // Query dùng cho lọc, sắp xếp hoặc tùy chọn. Dùng Uri để encode ký tự,
          // tránh ghép chuỗi thủ công khi dữ liệu có dấu cách, &, # hoặc tiếng Việt.
          context.go(
            Uri(
              path: '/products',
              queryParameters: {
                'sort': sort == 'asc' ? 'desc' : 'asc',
                'q': 'học Flutter',
              },
            ).toString(),
          );
        }),
        for (final id in sortedIds)
          DemoAction('Sản phẩm $id: ${demoProducts[id]}', () {
            // Router ghép path /products/:id từ name. Không viết lại path ở UI.
            context.goNamed(
              RouteNames.product,
              pathParameters: {'id': id},
              queryParameters: {'source': 'list'},
            );
          }),
        DemoAction('pushNamed + extra object', () {
          context.pushNamed(
            RouteNames.product,
            pathParameters: {'id': '1'},
            extra: const ProductPreview('1', 'Tên từ object extra'),
          );
        }),
        const RouteSnapshot(),
      ],
    );
  }
}

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key, required this.id, this.preview});
  final String id;
  final ProductPreview? preview;

  @override
  Widget build(BuildContext context) {
    // id trên URL là nguồn định danh. extra chỉ là dữ liệu bổ sung/tối ưu hiển thị.
    // Copy URL sang máy khác vẫn phải mở được màn hình, không ép extra! gây crash.
    final title = preview?.id == id ? preview!.title : demoProducts[id];
    if (title == null) {
      // URL hợp lệ nhưng dữ liệu không tồn tại là lỗi nghiệp vụ, không phải lỗi
      // match route. errorBuilder của GoRouter không tự xử lý trường hợp này.
      return StudyPage(
        title: 'Không có sản phẩm',
        children: [
          Text('Không tìm thấy id=$id'),
          DemoAction(
            'Về danh sách',
            () => context.goNamed(RouteNames.products),
          ),
        ],
      );
    }
    return StudyPage(
      title: 'Chi tiết sản phẩm $id',
      children: [
        Text(title),
        Text(
          preview == null
              ? 'extra: không có, dùng dữ liệu theo id'
              : 'extra: có',
        ),
        DemoAction('Mở reviews bằng đường dẫn tương đối', () {
          // ./ được giải theo location hiện tại, ví dụ /products/1 → /products/1/reviews.
          // Đây vẫn là go: stack được suy ra từ cây GoRoute cha/con.
          context.go('./reviews');
        }),
        DemoAction('Tạo URL bằng namedLocation', () {
          final location = context.namedLocation(
            RouteNames.reviews,
            pathParameters: {'id': id},
            queryParameters: {'page': '2'},
          );
          // namedLocation chỉ tạo String; go mới thực hiện điều hướng.
          context.go(location);
        }),
        const Text(
          'Back từ reviews → chi tiết → danh sách, kể cả mở deep link trực tiếp.',
        ),
        const RouteSnapshot(),
      ],
    );
  }
}

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) => StudyPage(
    title: 'Reviews sản phẩm $id',
    children: const [
      Text(
        'Đây là route con của :id, bản thân :id là route con của /products.',
      ),
      RouteSnapshot(),
    ],
  );
}
