import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'session.dart';

/// widget common dùng chung cho nhiều màn hình
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
      // Thay đổi giá trị của  refreshListenable làm chạy redirect / -> /homeScreen.
      // LandingScreen là tab đầu của app, nên bottom bar xuất hiện ngay.

      onPressed: session.login,
      child: const Text('Đăng nhập'),
    ),
    TextButton(
      // Đi thẳng tới URL chi tiết khi chưa đăng nhập.
      //redirect giữ URL này trong ?from=...
      onPressed: () => context.goNamed('product', pathParameters: {'id': '42'}),
      child: const Text('Xem sản phẩm demo'),
    ),
  ]);
}

// Màn hình HomeScreen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String result = 'Chưa chọn';

  Future<void> openPicker() async {
    // push đặt /homeScreen/pick lên trên tab Home.
    // Future nhận giá trị từ pop ở PickScreen.
    // Bấm Back mà không chọn sẽ trả null.
    debugPrint("[HomeScreen] _openPicker run");
    // Hàm chỉ chạy tới đây thôi --- khi nào ở màn pick pop về thì mới chạy nốt đoạn đằng sau
    final value = await context.push<String>('/homeScreen/pick');
    // Push tới hàm chọn giá trị - Và khi nhận được pop từ màn pick thì sẽ nhận ở đây
    debugPrint("[HomeScreen] _openPicker value: $value");
    if (!mounted) return; // Widget có thể đã bị hủy trong lúc chờ Future.
    setState(() => result = value ?? 'Đã hủy');
  }

  @override
  Widget build(BuildContext context) => DemoPage('Ví dụ navigation', [
    Text('Kết quả từ push/pop: $result'),
    // Màn hình demo gửi lại giá trị tới màn cũ
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
      // pop đóng trang hiện tại và gửi 1 data String cho Future của push.
      onPressed: () => context.pop('Flutter'),
      child: const Text('Chọn Flutter'),
    ),
    TextButton(onPressed: () => context.pop(), child: const Text('Hủy')),
  ]);
}

// Widget vẽ lên BottomNavigationBar - sẽ được sử dụng ở StateShellRoute
class TabsScreen extends StatelessWidget {
  const TabsScreen({required this.shell, super.key});
  // StatefulNavigationShell sẽ được StatefulShellRoute cung cấp
  final StatefulNavigationShell shell;
  // shell đóng 2 vai trò
  // 1. cung cấp widget hiển thị tab đang hoat động
  // 2. cung cấp index của tab đang được hiển thị qua currentIndex

  @override
  Widget build(BuildContext context) => Scaffold(
    body: shell, // Đặt nội dung của branch đang chọn vào phần thân
    // Giữ thanh chọn tab bên dưới nội dung - giao diện sẽ được vẽ bằng NaigationBar
    bottomNavigationBar: NavigationBar(
      // index của branch đang họat động trong danh sách branches
      selectedIndex: shell.currentIndex,
      // Hàm sẽ chạy khi người dùng bấm 1 tab - index của tab sẽ là tham số
      onDestinationSelected: (index) {
        debugPrint('[TabScreen] onDestinationSelected index :  $index');
        debugPrint('[TabScreen] onDestinationSelected shell :  $shell');
        // goBranch chuyển tab mà vẫn giữ stack riêng của tab cũ.
        // Bấm lại tab đang chọn thì về route gốc của tab đó.
        // navigationShell.goBranch(0) : Chuyển sang branch tương ứng
        shell.goBranch(index, initialLocation: index == shell.currentIndex);
        //  Tham số thứ 2 quyết định đi về route gốc hay khôi phục vị trí trước đó của branch
        // initialLocation ở đây là route gốc của brach được chọn - không phải của toàn bộ GoRouter
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.school), label: 'Trang chủ'),
        NavigationDestination(icon: Icon(Icons.list), label: 'Sản phẩm'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Tài khoản'),
      ],
    ),
  );
}

// Màn hình sản phẩm
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
      onPressed: () => context.go('/homeScreen'),
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

// Màn hình review ở bên trong nội bộ màn sản phẩm
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

//  Màn hình tài khoản
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
        router.go('/'); // Trở về màn hình LandingScreen chưa đăng nhập
      },
      child: const Text('Đăng xuất'),
    ),
  ]);
}

// Màn hình lỗi nếu không có url đúng
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => DemoPage('Không tìm thấy trang', [
    Text(message),
    TextButton(
      onPressed: () => context.go('/homeScreen'),
      child: const Text('Về tab Ví dụ'),
    ),
  ]);
}

// Phân biệt go và push
// go dựng các màn được cấu hình cho route đích,
// còn push thêm màn vào stack để có thể pop trở lại.

// push và pushNamed còn trả về Future<T?>: màn mở lên có thể gọi context.pop(result) để gửi kết quả về nơi đã push
// go và goNamed trả về void, nên không dùng theo kiểu chờ kết quả đó.

/**
 Khi gọi context.goNamed('product', pathParameters: {'id': '7'}), URL đích là /products/7.
  Để khớp URL này, go_router đi qua cả hai route: /products rồi :id.
   Vì vậy stack của tab Sản phẩm có thể hình dung là:
ProductsScreen → ProductScreen(id: 7)
Nếu đang ở chi tiết sản phẩm 7 và gọi context.pop(), màn chi tiết được đóng, để lộ ProductsScreen bên dưới.

Điểm phân biệt sẽ rõ hơn khi đang xem sản phẩm 42 rồi mở sản phẩm 7:
- goNamed('product', id: '7'): dựng stack theo đích → [Danh sách, Sản phẩm 7]. Back về Danh sách.
- pushNamed('product', id: '7'): thêm màn mới vào stack hiện tại → [Danh sách, Sản phẩm 42, Sản phẩm 7]. Back về Sản phẩm 42.
Vậy go không giữ màn trước đó chỉ vì bạn vừa ở đó; nhưng nó vẫn dựng route cha mà URL đích cần.
 */
