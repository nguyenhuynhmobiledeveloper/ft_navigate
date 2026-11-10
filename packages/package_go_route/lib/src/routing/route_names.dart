/// Tên route khác với đường dẫn URL. name phải duy nhất trong một GoRouter.
/// Đổi path mà giữ name giúp lời gọi goNamed/pushNamed ít phải sửa hơn.
abstract final class RouteNames {
  static const home = 'home';
  static const products = 'products';
  static const product = 'product';
  static const reviews = 'reviews';
  static const login = 'login';
  static const account = 'account';
}
