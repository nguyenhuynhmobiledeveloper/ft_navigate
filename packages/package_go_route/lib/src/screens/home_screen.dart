import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/typed_routes.dart';
import '../widgets/study_page.dart';

/**
 context.go()
Điều hướng trực tiếp đến một location.

Đặc điểm:
- Chuyển sang một location mới.
- Router xây dựng lại stack theo cấu trúc route match của location đó.
- Không đơn giản là thêm một màn hình lên trên màn hình hiện tại.

Đây là cách phù hợp khi:
- Chuyển tab Bottom Navigation.
- Đăng nhập thành công.
- Logout.
- Chuyển từ onboarding sang Home.
- Điều hướng đến một khu vực chính khác của ứng dụng.

context.push()
Đẩy thêm một màn hình vào stack.

Đây là cách phù hợp khi:
- Mở chi tiết sản phẩm.
- Mở chi tiết bài viết.
- Mở trang chỉnh sửa thông tin.
- Mở trang xem chi tiết đơn hàng.

Ngoài ra, push() có thể nhận kiểu dữ liệu trả về:

context.pop()
Quay lại màn hình trước hoặc đóng route hiện tại. - có thể trả dữ liệu về màn cũ

context.replace()
Thay thế route hiện tại bằng route mới.
Khác với go(), phương thức này thực hiện thay thế route hiện tại trong navigation history thay vì điều hướng trực tiếp theo kiểu declarative như go().


context.pushReplacement()
Thay thế route hiện tại bằng route mới theo kiểu imperative push.
Login
  |
  | pushReplacement()
  v
Home

Khi Back, người dùng không quay lại Login thông qua route vừa bị thay thế.
 */

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => StudyPage(
    title: 'Thực hành go_router',
    showHome: false,
    children: [
      const Text(
        'Mỗi mục là một bài thực hành. Đọc README và comment trong routing/demo_navigation.dart trước.',
      ),
      DemoAction('1. go, push, pop và kết quả', () => context.go('/stack')),
      DemoAction(
        '2. Path, query, name, extra, nested route',
        () => context.go('/products'),
      ),
      DemoAction(
        '3. ShellRoute: một Navigator con',
        () => context.go('/workspace'),
      ),
      DemoAction(
        '4. StatefulShellRoute: giữ stack từng tab',
        () => context.go('/tabs/feed'),
      ),
      DemoAction(
        '5. Redirect đăng nhập và quyền',
        () => context.go('/account?source=home'),
      ),
      DemoAction(
        '6. onExit: xác nhận rời màn hình',
        () => context.push('/editor'),
      ),
      DemoAction('7. CustomTransitionPage', () => context.push('/transition')),
      DemoAction('8. NoTransitionPage', () => context.push('/no-transition')),
      DemoAction('9. CupertinoPage', () => context.push('/cupertino')),
      DemoAction(
        '10. Typed route',
        () => const TypedBookRoute(bookId: 42, page: 2).go(context),
      ),
      DemoAction('11. State restoration', () => context.go('/restore')),
      DemoAction(
        '12. onEnter, route động và xử lý lỗi',
        () => context.go('/advanced'),
      ),
      DemoAction(
        '13. State và NavigatorObserver',
        () => context.go('/inspect'),
      ),
    ],
  );
}
