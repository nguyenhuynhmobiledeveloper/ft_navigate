import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void runGoRouteNavigationBarApp() => runApp(const GoRouteNavigationBarApp());

const _background = Color(0xFFF6F7F9);
const _blue = Color(0xFF0046C8);
const _dark = Color(0xFF484D60);

// Thứ tự ở đây là thứ tự branch của router và thứ tự nút trên thanh điều hướng.
const _tabs = [
  NavigationTab('/', 'Trang chủ', Icons.home_rounded),
  NavigationTab('/history', 'Lịch sử', Icons.description_outlined),
  NavigationTab('/invest', 'Đầu tư', Icons.add),
  NavigationTab('/assets', 'Tài sản', Icons.account_balance_wallet_outlined),
  NavigationTab('/profile', 'Cá nhân', Icons.account_circle_outlined),
];

// model của 1 thanh Tab
class NavigationTab {
  const NavigationTab(this.path, this.label, this.icon);
  final String path;
  final String label;
  final IconData icon;
}

class TabScreen extends StatelessWidget {
  const TabScreen({super.key, required this.tab});

  final NavigationTab tab;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Màn hình ${tab.label}'));
  }
}

// widget chính của app
class GoRouteNavigationBarApp extends StatefulWidget {
  const GoRouteNavigationBarApp({super.key});

  @override
  State<GoRouteNavigationBarApp> createState() =>
      _GoRouteNavigationBarAppState();
}

class _GoRouteNavigationBarAppState extends State<GoRouteNavigationBarApp> {
  // Khai báo biến GoRouter
  late final GoRouter _router = GoRouter(
    routes: [
      // Mỗi tab có Navigator riêng. Khi đổi tab rồi quay lại, branch giữ vị trí.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _TabsScaffold(shell: shell),
        branches: [
          for (final tab in _tabs)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: tab.path,
                  // Màn hình chính của 1 tab
                  builder: (context, state) => TabScreen(tab: tab),
                ),
              ],
            ),
        ],
      ),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    routerConfig: _router,
  );
}

class _TabsScaffold extends StatelessWidget {
  const _TabsScaffold({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _background,
    body: shell,
    // Tô nền ở NGOÀI SafeArea để màu trắng phủ cả vùng home indicator iPhone.
    bottomNavigationBar: ColoredBox(
      // color: Colors.white,
      color: Colors.red,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 126,
          child: Stack(
            children: [
              // Chỉ khoảng phía trên thanh tab giữ màu nền màn hình.
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 26,
                child: ColoredBox(color: _background),
              ),
              // Nền trắng của thanh tab, chừa khoảng trống phía trên cho nút +.
              Positioned(
                left: 0,
                right: 0,
                top: 26,
                bottom: 12,
                child: ColoredBox(
                  color: Colors.white,
                  child: Row(
                    children: [
                      for (var index = 0; index < _tabs.length; index++)
                        Expanded(
                          child: _TabButton(
                            tab: _tabs[index],
                            selected: shell.currentIndex == index,
                            onTap: () => shell.goBranch(
                              index,
                              initialLocation: index == shell.currentIndex,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Nút tròn nằm đè lên mép trên; vùng chạm vẫn gọi goBranch(2).
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Semantics(
                    label: 'Đầu tư',
                    button: true,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => shell.goBranch(
                        2,
                        initialLocation: shell.currentIndex == 2,
                      ),
                      child: Container(
                        width: 68,
                        height: 68,
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE6ECF8),
                          shape: BoxShape.circle,
                        ),
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            color: _blue,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add, color: Colors.white, size: 32),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final NavigationTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Column(
      children: [
        // Nút + thật nằm trên thanh nên ô giữa chỉ cần nhãn ở cùng hàng.
        SizedBox(height: tab.path == '/invest' ? 45 : 12),
        if (tab.path != '/invest')
          Icon(tab.icon, size: 27, color: selected ? _blue : _dark),
        if (tab.path != '/invest') const SizedBox(height: 7),
        Text(
          tab.label,
          maxLines: 1,
          style: TextStyle(fontSize: 15, color: selected ? _blue : _dark),
        ),
      ],
    ),
  );
}
