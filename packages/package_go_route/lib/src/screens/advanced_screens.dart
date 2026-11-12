import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../demo_state.dart';
import '../widgets/study_page.dart';

class AdvancedScreen extends StatefulWidget {
  const AdvancedScreen({
    super.key,
    required this.journal,
    required this.experimentalEnabled,
    required this.setExperimental,
    required this.entryAllowed,
    required this.setEntryAllowed,
    required this.navigateWithoutContext,
  });
  final NavigationJournal journal;
  final bool Function() experimentalEnabled;
  final ValueChanged<bool> setExperimental;
  final bool Function() entryAllowed;
  final ValueChanged<bool> setEntryAllowed;
  final VoidCallback navigateWithoutContext;

  @override
  State<AdvancedScreen> createState() => _AdvancedScreenState();
}

class _AdvancedScreenState extends State<AdvancedScreen> {
  @override
  Widget build(BuildContext context) => StudyPage(
    title: 'Guard, route động, lỗi',
    children: [
      SwitchListTile(
        title: const Text('Cho phép vào /guarded'),
        value: widget.entryAllowed(),
        onChanged: (value) => setState(() => widget.setEntryAllowed(value)),
      ),
      // Điều hướng trực tiếp đến một location
      // Đặc điểm chuyển sang 1 location mới
      // Router xây dựng lại stack theo cấu trúc route match của location đó
      // Không đơn giản là thêm 1 màn hình lên trên màn hình hiện tại

      DemoAction('Thử onEnter', () => context.go('/guarded')),
      ValueListenableBuilder<List<String>>(
        valueListenable: widget.journal,
        builder: (_, entries, __) => Text(entries.isEmpty ? '' : entries.first),
      ),
      SwitchListTile(
        title: const Text('Thêm route /experimental lúc chạy'),
        value: widget.experimentalEnabled(),
        onChanged: (value) => setState(() => widget.setExperimental(value)),
      ),
      DemoAction('Mở /experimental', () => context.go('/experimental')),
      DemoAction('Thử URL không tồn tại', () => context.go('/khong-ton-tai')),
      DemoAction('Thử redirect loop', () => context.go('/loop-a')),
      DemoAction(
        'Route redirect: /legacy → sản phẩm 1',
        () => context.go('/legacy'),
      ),
      DemoAction(
        'Gọi router không qua BuildContext',
        widget.navigateWithoutContext,
      ),
      DemoAction('refresh: đánh giá lại route hiện tại', () {
        // refresh không mặc định tải lại dữ liệu nghiệp vụ. Nó yêu cầu router
        // phân tích lại trạng thái và redirect; repository cần refresh riêng.
        GoRouter.of(context).refresh();
      }),
      DemoAction('Router.neglect + query lặp + fragment', () {
        // API của Flutter Router, hữu ích trên web: không thêm browser-history
        // entry mới cho lần điều hướng này. URL hiện tại vẫn có thể được cập nhật.
        Router.neglect(
          context,
          () => context.go('/inspect?tag=flutter&tag=navigation#vi-du'),
        );
      }),
    ],
  );
}

class InspectScreen extends StatelessWidget {
  const InspectScreen({super.key, required this.journal});
  final NavigationJournal journal;

  @override
  Widget build(BuildContext context) => StudyPage(
    title: 'GoRouterState và observer',
    children: [
      const RouteSnapshot(),
      const Text('Nhật ký Page, mới nhất trước:'),
      ValueListenableBuilder<List<String>>(
        valueListenable: journal,
        builder: (_, entries, __) => Text(entries.join('\n')),
      ),
    ],
  );
}

class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({super.key, required this.state});
  final GoRouterState state;

  @override
  Widget build(BuildContext context) => StudyPage(
    title: 'Không mở được route',
    children: [
      Text('URL: ${state.uri}'),
      Text('Lỗi router: ${state.error}'),
      DemoAction('Về trang chủ', () => context.go('/')),
    ],
  );
}
