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

/// Trang đầu chỉ đưa ra hai lối vào để thấy rõ tác dụng của auth redirect.
/// Màn hình LandingScreen khi app đang ở trạng thái chưa đăng nhập
class LandingScreen extends StatelessWidget {
  const LandingScreen({required this.session, super.key});

  final DemoSession session;

  @override
  Widget build(BuildContext context) => DemoPage('Bắt đầu', [
    TextButton(
      // thay đổi giá trị của  refreshListenable làm chạy redirect / -> /examples.
      // /examples là tab đầu của app, nên bottom bar xuất hiện ngay.

      onPressed: session.login,
      child: const Text('Đăng nhập'),
    ),
    TextButton(
      // Đi thẳng tới URL chi tiết khi chưa đăng nhập. redirect giữ URL này
      // trong ?from=... và trang đăng nhập giải thích vì sao chưa xem được.
      onPressed: () => context.goNamed('product', pathParameters: {'id': '42'}),
      child: const Text('Xem sản phẩm demo'),
    ),
  ]);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String result = 'Chưa chọn';

  Future<void> openPicker() async {
    // push đặt /examples/pick lên trên tab Ví dụ.
    // Future nhận giá trị từ pop ở PickScreen.
    // Bấm Back mà không chọn sẽ trả null.
    final value = await context.push<String>('/examples/pick');
    if (!mounted) return; // Widget có thể đã bị hủy trong lúc chờ Future.
    setState(() => result = value ?? 'Đã hủy');
  }

  @override
  Widget build(BuildContext context) => DemoPage('Ví dụ navigation', [
    Text('Kết quả từ push/pop: $result'),
    TextButton(onPressed: openPicker, child: const Text('push: chọn giá trị')),
    // go chuyển sang tab Sản phẩm theo URL đích.
    TextButton(
      onPressed: () => context.go('/products'),
      child: const Text('go: danh sách sản phẩm'),
    ),
    TextButton(
      onPressed: () => context.go('/account'),
      child: const Text('go: tài khoản'),
    ),
    TextButton(
      onPressed: () => context.go('/khong-ton-tai'),
      child: const Text('Thử URL không tồn tại'),
    ),
  ]);
}

// Màn hình chọn  1 giá trị rồi pop về màn cũ
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

// Widget chứa BottomNavigationBar
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
        // navigationShell.goBranch(0) : Chuyển sang branch tương ứng
        shell.goBranch(index, initialLocation: index == shell.currentIndex);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.school), label: 'Ví dụ'),
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
      onPressed: () => context.go('/examples'),
      child: const Text('Về tab Ví dụ'),
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

// Màn hình đăng nhập
class LoginScreen extends StatelessWidget {
  const LoginScreen({required this.session, this.from, super.key});

  final DemoSession session;
  final String? from;

  @override
  Widget build(BuildContext context) {
    final segments = Uri.tryParse(from ?? '')?.pathSegments ?? [];
    final productId = segments.length >= 2 && segments.first == 'products'
        ? segments[1]
        : null;
    return DemoPage('Yêu cầu đăng nhập', [
      Text(
        productId == null
            ? 'Bạn cần đăng nhập để tiếp tục.'
            : 'Bạn cần đăng nhập để xem sản phẩm $productId.',
      ),
      TextButton(
        // notifyListeners làm router chạy lại redirect. Router tự đi tới
        // URL trong ?from=..., nên ở đây không cần gọi context.go lần nữa.
        onPressed: session.login,
        child: const Text('Đăng nhập'),
      ),
    ]);
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({required this.session, super.key});

  final DemoSession session;

  @override
  Widget build(BuildContext context) => DemoPage('Tài khoản', [
    const Text('Đã đăng nhập.'),
    TextButton(
      // Đổi trạng thái trước, rồi yêu cầu router về trang đầu một lần.
      // Lệnh go bên dưới chạy redirect với signedIn == false.
      onPressed: () {
        final router = GoRouter.of(context);
        session.logout(notify: false);
        router.go('/'); // Trở về màn hình home chưa đăng nhập
      },
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
      onPressed: () => context.go('/examples'),
      child: const Text('Về tab Ví dụ'),
    ),
  ]);
}
