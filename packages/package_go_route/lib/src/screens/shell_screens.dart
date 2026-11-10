import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/study_page.dart';

class WorkspaceShell extends StatelessWidget {
  const WorkspaceShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    // child là Navigator do ShellRoute tạo. Không tự tạo Navigator khác ở đây.
    body: child,
    bottomNavigationBar: SafeArea(
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
        children: [
          const Text('ShellRoute đang hiện'),
          TextButton(
            onPressed: () => context.go('/workspace'),
            child: const Text('Tổng quan'),
          ),
          TextButton(
            onPressed: () => context.go('/workspace/settings'),
            child: const Text('Cài đặt'),
          ),
        ],
      ),
    ),
  );
}

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key, this.settings = false});
  final bool settings;

  @override
  Widget build(BuildContext context) => StudyPage(
    title: settings ? 'Cài đặt workspace' : 'Workspace',
    children: [
      const Text(
        'ShellRoute dùng một Navigator con chung; khung bên ngoài được giữ khi chuyển route con.',
      ),
      DemoAction('Mở trang phủ toàn bộ shell', () {
        // Route này cấu hình parentNavigatorKey=rootKey. Nó được đặt trên
        // root Navigator nên che luôn thanh điều hướng của WorkspaceShell.
        context.push('/workspace/full-screen');
      }),
      const RouteSnapshot(),
    ],
  );
}

class TabsShell extends StatelessWidget {
  const TabsShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) => Scaffold(
    // indexedStack giữ các branch Navigator trong bộ nhớ, kể cả tab đang ẩn.
    body: navigationShell,
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      onTap: (index) {
        // Khác tab: quay lại location cuối cùng của branch đó.
        // Bấm lại tab đang chọn: về initialLocation (reset stack của tab).
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Bảng tin'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Đã lưu'),
      ],
    ),
  );
}

class BranchScreen extends StatefulWidget {
  const BranchScreen({super.key, required this.branch});
  final String branch;

  @override
  State<BranchScreen> createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchScreen> {
  int count = 0;

  @override
  Widget build(BuildContext context) => StudyPage(
    title: 'Tab ${widget.branch}',
    children: [
      Text('Bộ đếm ${widget.branch}: $count'),
      DemoAction('Tăng bộ đếm tab', () => setState(() => count++)),
      DemoAction(
        'Mở chi tiết trong tab',
        () => context.go('/tabs/${widget.branch}/item/7'),
      ),
      const Text(
        'Tăng bộ đếm, mở chi tiết rồi đổi tab và quay lại. Stack và State vẫn còn. '
        'Đây là giữ state trong bộ nhớ, không phải lưu dữ liệu vĩnh viễn.',
      ),
    ],
  );
}
