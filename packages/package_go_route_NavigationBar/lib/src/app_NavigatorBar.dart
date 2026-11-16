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

// Phần thân ruột của màn hình : body nội dung nằm phía trên bottomTabBar
class TabBodyScreen extends StatelessWidget {
  const TabBodyScreen({super.key, required this.tab});

  final NavigationTab tab;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Màn hình ${tab.label}'));
  }
}

// Tab Đầu tư vẫn nằm trong shell nên luôn thấy bottom tab bar.
class InvestTabScreen extends StatelessWidget {
  const InvestTabScreen({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Màn hình Đầu tư'),
        ElevatedButton(
          // push route con lên root Navigator để trang chi tiết che shell.
          onPressed: () => context.push('/invest/details'),
          child: const Text('Chi tiết'),
        ),
      ],
    ),
  );
}

class InvestDetailScreen extends StatelessWidget {
  const InvestDetailScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _background,
    appBar: AppBar(
      backgroundColor: _background,
      leading: BackButton(onPressed: () => context.pop()),
      title: const Text('Chi tiết Đầu tư'),
    ),
    body: const Center(child: Text('Màn hình Chi tiết Đầu tư')),
  );
}

// widget chính của app - chỉ chứa cấu hình điều hướng - không có view trực tiếp
class GoRouteNavigationBarApp extends StatefulWidget {
  const GoRouteNavigationBarApp({super.key});

  @override
  State<GoRouteNavigationBarApp> createState() =>
      _GoRouteNavigationBarAppState();
}

class _GoRouteNavigationBarAppState extends State<GoRouteNavigationBarApp> {
  final _rootNavigatorKey = GlobalKey<NavigatorState>();

  // Khai báo biến GoRouter
  late final GoRouter _router = GoRouter(
    // Đây là navigator gốc - để điều khiển 1 vài màn hình không hiển thị bottom tab bar
    // mà hiển thị đè lên trên bottom tab bar
    navigatorKey: _rootNavigatorKey,
    routes: [
      // Cả 5 tab đều nằm trong shell, mỗi tab có Navigator riêng.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _TabsScaffold(shell: shell),

        // Các nhánh navigate trong StatefulShellRoute
        branches: [
          for (final tab in _tabs)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: tab.path,
                  // Màn hình chính của 1 tab luôn nằm trên bottom tab bar.
                  builder: (context, state) => tab.path == '/invest'
                      ? const InvestTabScreen()
                      : TabBodyScreen(tab: tab),
                  routes: [
                    if (tab.path == '/invest')
                      GoRoute(
                        path: 'details',
                        // Trang con thuộc nhánh Đầu tư nhưng hiển thị trên
                        // root Navigator, phủ cả shell và bottom tab bar.
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => const InvestDetailScreen(),
                      ),
                  ],
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
    theme: ThemeData(useMaterial3: true),
    routerConfig: _router,
  );
}

// NavigationBar Material 3 tự tô nền cả vùng SafeArea dưới màn hình.
// Xem đủ 17 tham số constructor của NavigationBar ngay trong widget bên dưới.
class _TabsScaffold extends StatelessWidget {
  const _TabsScaffold({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _background,
    body: shell,
    bottomNavigationBar: NavigationBar(
      // key: Key?; mặc định null. ValueKey nhận giá trị ổn định, ObjectKey nhận
      // object, UniqueKey luôn mới, GlobalKey giữ định danh duy nhất trong cây.
      // Chỉ cần đặt khi muốn nhận diện hoặc điều khiển riêng widget này.
      // key: const ValueKey('main-navigation-bar'),

      // animationDuration: Duration?; mặc định 500 ms. Duration.zero đổi ngay;
      // Duration dương là thời gian chuyển từ chưa chọn sang đã chọn và ngược lại.
      // animationDuration: const Duration(milliseconds: 500),

      // selectedIndex: int; mặc định 0, hợp lệ từ 0 đến destinations.length-1.
      // Ở đây chỉ số tab do go_router quản lý, không lưu thêm state riêng.
      selectedIndex: shell.currentIndex,

      // destinations: List<Widget>; bắt buộc, không có mặc định, ít nhất 2
      // phần tử. Mỗi NavigationDestination là một điểm đến; thứ tự phải khớp
      // với các StatefulShellBranch trong router.
      destinations: [
        for (final tab in _tabs)
          NavigationDestination(
            // key: Key?; mặc định null. ValueKey/ObjectKey giữ định danh theo
            // giá trị/object; UniqueKey luôn mới; GlobalKey duy nhất trong cây.
            // key: ValueKey(tab.path),

            // icon: Widget; bắt buộc, không có mặc định. Nhận Icon hoặc Widget
            // bất kỳ; đây là hình khi điểm đến chưa được chọn.
            icon: tab.path == '/invest'
                ? const _InvestIcon()
                : Icon(tab.icon, size: 27, color: _dark),

            // selectedIcon: Widget?; mặc định null thì dùng lại icon. Widget
            // khác sẽ thay icon khi chọn. Tab thường chuyển xanh, Đầu tư vẫn
            // giữ nút tròn xanh ở cả hai trạng thái.
            selectedIcon: tab.path == '/invest'
                ? const _InvestIcon()
                : Icon(tab.icon, size: 27, color: _blue),

            // label: String; bắt buộc, không có mặc định. Nhận chuỗi bất kỳ;
            // việc hiện/ẩn nhãn do labelBehavior của NavigationBar quyết định.
            label: tab.label,

            // tooltip: String?; mặc định null thì dùng label khi nhấn giữ.
            // Chuỗi khác thay nội dung tooltip; chuỗi rỗng '' tắt tooltip.
            // tooltip: tab.label,

            // enabled: bool; mặc định true cho phép chọn; false vô hiệu hóa
            // thao tác và dùng màu disabled của theme.
            // enabled: true,
          ),
      ],

      // onDestinationSelected: ValueChanged<int>?; mặc định null nghĩa là
      // bấm tab không gọi callback. Callback nhận chỉ số 0..n-1; goBranch đổi
      // Navigator của tab. Bấm lại tab hiện tại để về route gốc của tab.
      onDestinationSelected: (index) =>
          shell.goBranch(index, initialLocation: index == shell.currentIndex),

      // backgroundColor: Color?; mặc định null => NavigationBarThemeData,
      // rồi ColorScheme.surfaceContainer trong Material 3. Nhận bất kỳ Color:
      // trắng tô cả vùng home indicator, transparent cho nền trong suốt.
      backgroundColor: Colors.white,

      // elevation: double?; mặc định null => theme, rồi 3.0 ở Material 3
      // (0.0 ở Material 2). 0 phẳng, số dương làm thanh nổi và có thể có bóng.
      elevation: 0,

      // shadowColor: Color?; mặc định null => theme, rồi transparent.
      // Màu khác đổi bóng; transparent làm bóng không nhìn thấy.
      // shadowColor: Colors.transparent,

      // surfaceTintColor: Color?; mặc định null => theme, rồi transparent.
      // Màu khác phủ tint theo elevation; transparent không phủ. Material 3
      // hiện không khuyến khích tùy chỉnh surface tint.
      // surfaceTintColor: Colors.transparent,

      // indicatorColor: Color?; mặc định null => theme, rồi
      // ColorScheme.secondaryContainer ở Material 3. Màu khác tô vùng chọn;
      // transparent giấu nền chỉ báo nhưng vẫn giữ trạng thái chọn.
      indicatorColor: Colors.transparent,

      // indicatorShape: ShapeBorder?; mặc định null => theme, rồi
      // StadiumBorder ở Material 3 (viên thuốc), RoundedRectangleBorder bo
      // góc 16 ở Material 2. Có thể dùng CircleBorder hoặc ShapeBorder khác.
      // indicatorShape: const StadiumBorder(),

      // height: double?; mặc định null => theme, rồi 80 logical pixel.
      // Số dương thay chiều cao thanh; SafeArea dưới máy được cộng thêm.
      height: 96,

      // labelBehavior: NavigationDestinationLabelBehavior?; mặc định null =>
      // theme, rồi alwaysShow. alwaysShow: hiện mọi nhãn;
      // onlyShowSelected: chỉ hiện nhãn tab chọn; alwaysHide: ẩn tất cả.
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

      // overlayColor: WidgetStateProperty<Color?>?; mặc định null => theme,
      // rồi hiệu ứng InkResponse mặc định. Có thể trả màu theo pressed,
      // hovered, focused; trả null để trạng thái đó dùng màu mặc định.
      // overlayColor: WidgetStateProperty.all(Colors.transparent),

      // labelTextStyle: WidgetStateProperty<TextStyle?>?; mặc định null =>
      // theme, rồi textTheme.labelMedium: selected dùng onSurface,
      // unselected dùng onSurfaceVariant, disabled mờ 38% (Material 3).
      // Có thể đổi cỡ chữ, font và màu theo WidgetState; null dùng mặc định.
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 14,
          color: states.contains(WidgetState.selected) ? _blue : _dark,
        ),
      ),

      // labelPadding: EdgeInsetsGeometry?; mặc định null => theme, rồi
      // EdgeInsets.only(top: 4). EdgeInsets đặt khoảng cố định;
      // EdgeInsetsDirectional đặt khoảng theo chiều chữ LTR/RTL.
      // labelPadding: const EdgeInsets.only(top: 4),

      // maintainBottomViewPadding: bool; mặc định false: SafeArea dùng padding
      // hiện tại, có thể đổi khi bàn phím mở. true: giữ viewPadding ban đầu,
      // tránh thanh nhảy khi bàn phím xuất hiện ở chế độ edge-to-edge.
      // maintainBottomViewPadding: false,
    ),
  );
}

// Nút Đầu tư vẫn là icon của NavigationDestination. NavigationBar quản lý
// vùng chạm, tooltip, semantics và trạng thái chọn cho nút này.
class _InvestIcon extends StatelessWidget {
  const _InvestIcon();

  @override
  Widget build(BuildContext context) => Container(
    width: 54,
    height: 54,
    decoration: BoxDecoration(
      color: _blue,
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFFE6ECF8), width: 4),
    ),
    child: const Icon(Icons.add, color: Colors.white, size: 30),
  );
}
