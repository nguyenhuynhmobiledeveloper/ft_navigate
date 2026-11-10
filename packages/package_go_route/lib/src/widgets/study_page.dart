import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Gói phần UI lặp lại để các file bài học chủ yếu chứa code navigation.
class StudyPage extends StatelessWidget {
  const StudyPage({
    super.key,
    required this.title,
    required this.children,
    this.showHome = true,
  });

  final String title;
  final List<Widget> children;
  final bool showHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: showHome
            ? IconButton(
                tooltip: 'Quay lại',
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // canPop kiểm tra stack của router. go('/...') không nhất thiết
                  // tạo trang để pop, ví dụ khi truy cập trực tiếp một deep link.
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              )
            : null,
        actions: [
          if (showHome)
            IconButton(
              tooltip: 'Về mục lục',
              icon: const Icon(Icons.home),
              onPressed: () => context.go('/'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final child in children)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: child),
        ],
      ),
    );
  }
}

class DemoAction extends StatelessWidget {
  const DemoAction(this.label, this.onPressed, {super.key});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      OutlinedButton(onPressed: onPressed, child: Text(label));
}

/// Đọc state thuộc route bao quanh widget này, không cần tự phân tích chuỗi URL.
class RouteSnapshot extends StatelessWidget {
  const RouteSnapshot({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    return SelectableText(
      'uri: ${state.uri}\n'
      'name: ${state.name}\n'
      'matchedLocation: ${state.matchedLocation}\n'
      'fullPath: ${state.fullPath}\n'
      'pathParameters: ${state.pathParameters}\n'
      'queryParametersAll: ${state.uri.queryParametersAll}\n'
      'fragment: ${state.uri.fragment}\n'
      'pageKey: ${state.pageKey.value}\n'
      'extra: ${state.extra?.runtimeType}',
    );
  }
}
