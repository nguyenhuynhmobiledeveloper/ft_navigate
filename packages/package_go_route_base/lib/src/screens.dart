import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'session.dart';

/// Một khung UI chung để phần ví dụ chỉ còn các lệnh điều hướng cần học.
class DemoPage extends StatelessWidget {
  const DemoPage(this.title, this.children, {super.key});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView(padding: const EdgeInsets.all(16), children: children),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String result = 'Chưa chọn';

  Future<void> openPicker() async {
    // push đặt /pick lên trên Home. Future nhận giá trị từ pop ở PickScreen.
    // Bấm Back mà không chọn sẽ trả null.
    final value = await context.push<String>('/pick');
    if (!mounted) return; // Widget có thể đã bị hủy trong lúc chờ Future.
    setState(() => result = value ?? 'Đã hủy');
  }

  @override
  Widget build(BuildContext context) => DemoPage('go_router cơ bản', [
    Text('Kết quả từ push/pop: $result'),
    TextButton(onPressed: openPicker, child: const Text('push: chọn giá trị')),
    // go chuyển tới URL đích theo cây route; Home không còn trong stack.
    TextButton(
      onPressed: () => context.go('/products'),
      child: const Text('go: danh sách sản phẩm'),
    ),
    TextButton(
      onPressed: () => context.go('/account'),
      child: const Text('go: tài khoản (cần đăng nhập)'),
    ),
    TextButton(
      onPressed: () => context.go('/khong-ton-tai'),
      child: const Text('Thử URL không tồn tại'),
    ),
  ]);
}

class PickScreen extends StatelessWidget {
  const PickScreen({super.key});

  @override
  Widget build(BuildContext context) => DemoPage('Chọn một giá trị', [
    TextButton(
      // pop đóng trang hiện tại và gửi String cho Future của push.
      onPressed: () => context.pop('Flutter'),
      child: const Text('Chọn Flutter'),
    ),
    TextButton(onPressed: () => context.pop(), child: const Text('Hủy')),
  ]);
}

class TabsScreen extends StatelessWidget {
  const TabsScreen({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: shell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: shell.currentIndex,
      onDestinationSelected: (index) {
        // goBranch chuyển tab mà vẫn giữ stack riêng của tab cũ.
        // Bấm lại tab đang chọn thì về route gốc của tab đó.
        shell.goBranch(index, initialLocation: index == shell.currentIndex);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.list), label: 'Sản phẩm'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Tài khoản'),
      ],
    ),
  );
}

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({required this.sort, super.key});

  final String sort;

  @override
  Widget build(BuildContext context) => DemoPage('Sản phẩm', [
    Text('Query sort: $sort'),
    TextButton(
      onPressed: () {
        // Uri tự mã hóa query parameter. go cập nhật URL và route hiện tại.
        final next = sort == 'normal' ? 'new' : 'normal';
        context.go(
          Uri(path: '/products', queryParameters: {'sort': next}).toString(),
        );
      },
      child: const Text('Đổi query sort'),
    ),
    TextButton(
      onPressed: () {
        // pushNamed tìm route theo name; pathParameters thay :id.
        // push giữ ProductsScreen phía dưới để Back quay về danh sách.
        context.pushNamed(
          'product',
          pathParameters: {'id': '42'},
          extra: 'Mở từ danh sách',
        );
      },
      child: const Text('pushNamed: sản phẩm 42'),
    ),
    TextButton(
      // goNamed tạo URL cùng route nhưng đi trực tiếp tới đích.
      // Có thể mở lại URL này bằng deep link; extra thì không đảm bảo còn.
      onPressed: () => context.goNamed('product', pathParameters: {'id': '7'}),
      child: const Text('goNamed: sản phẩm 7'),
    ),
    TextButton(
      onPressed: () => context.go('/'),
      child: const Text('Về trang đầu'),
    ),
  ]);
}

class ProductScreen extends StatelessWidget {
  const ProductScreen({required this.id, this.note, super.key});

  final String id;
  final String? note;

  @override
  Widget build(BuildContext context) => DemoPage('Sản phẩm $id', [
    Text('Path parameter id: $id'),
    Text('Extra: ${note ?? 'không có (ví dụ deep link)'}'),
    TextButton(
      // reviews là route con của product: URL /products/:id/reviews.
      // Truyền id vì name này cần :id từ route cha.
      onPressed: () => context.pushNamed('reviews', pathParameters: {'id': id}),
      child: const Text('Mở đánh giá'),
    ),
    TextButton(
      // canPop tránh gọi pop ở một stack không có trang để đóng.
      // Với deep link, route cha thường đã được router dựng bên dưới.
      onPressed: () =>
          context.canPop() ? context.pop() : context.go('/products'),
      child: const Text('Quay lại'),
    ),
  ]);
}

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) => DemoPage('Đánh giá sản phẩm $id', [
    const Text('Mở trực tiếp /products/42/reviews để thử route lồng.'),
    TextButton(
      onPressed: () => context.pop(),
      child: const Text('Back về sản phẩm'),
    ),
  ]);
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({required this.session, super.key});

  final DemoSession session;

  @override
  Widget build(BuildContext context) => DemoPage('Đăng nhập', [
    const Text('Demo chỉ dùng trạng thái trong bộ nhớ.'),
    TextButton(
      // notifyListeners làm router chạy lại redirect. Router tự đi tới
      // URL trong ?from=..., nên ở đây không cần gọi context.go lần nữa.
      onPressed: session.login,
      child: const Text('Đăng nhập'),
    ),
  ]);
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({required this.session, super.key});

  final DemoSession session;

  @override
  Widget build(BuildContext context) => DemoPage('Tài khoản', [
    const Text('Đã đăng nhập.'),
    TextButton(
      // Đổi session khiến refreshListenable kích hoạt redirect /login.
      onPressed: session.logout,
      child: const Text('Đăng xuất'),
    ),
  ]);
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => DemoPage('Không tìm thấy trang', [
    Text(message),
    TextButton(
      onPressed: () => context.go('/'),
      child: const Text('Về trang đầu'),
    ),
  ]);
}
