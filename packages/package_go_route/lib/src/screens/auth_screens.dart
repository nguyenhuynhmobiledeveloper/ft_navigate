import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../demo_state.dart';
import '../widgets/study_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.session, required this.from});
  final DemoSession session;
  final String? from;

  @override
  Widget build(BuildContext context) => StudyPage(
    title: 'Đăng nhập giả lập',
    children: [
      Text('Đăng nhập xong trở về: ${from ?? '/account'}'),
      const Text(
        'Mở /account hoặc /admin khi chưa đăng nhập để thấy redirect giữ URL đích.',
      ),
      // Không gọi context.go sau signIn: refreshListenable sẽ kích hoạt redirect.
      // Nếu tự go ở đây rồi redirect cũng go, hai nguồn điều hướng có thể đua nhau.
      DemoAction('Đăng nhập user', () => session.signIn()),
      DemoAction('Đăng nhập admin', () => session.signIn(admin: true)),
      const RouteSnapshot(),
    ],
  );
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.session});
  final DemoSession session;

  @override
  Widget build(BuildContext context) => StudyPage(
    title: 'Tài khoản',
    children: [
      Text('Vai trò: ${session.isAdmin ? 'admin' : 'user'}'),
      DemoAction('Trang quản trị', () => context.go('/admin')),
      // Sau notifyListeners, redirect thấy user ở route cần auth → /login?from=...
      DemoAction('Đăng xuất', session.signOut),
      const RouteSnapshot(),
    ],
  );
}
