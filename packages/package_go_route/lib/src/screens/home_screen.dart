import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/typed_routes.dart';
import '../widgets/study_page.dart';

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
