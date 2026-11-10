// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'typed_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$typedBookRoute];

RouteBase get $typedBookRoute => GoRouteData.$route(
  path: '/typed-book/:bookId',
  name: 'typed-book',
  factory: $TypedBookRoute._fromState,
);

mixin $TypedBookRoute on GoRouteData {
  static TypedBookRoute _fromState(GoRouterState state) => TypedBookRoute(
    bookId: int.parse(state.pathParameters['bookId']!),
    page: _$convertMapValue('page', state.uri.queryParameters, int.parse) ?? 1,
  );

  TypedBookRoute get _self => this as TypedBookRoute;

  @override
  String get location => GoRouteData.$location(
    '/typed-book/${Uri.encodeComponent(_self.bookId.toString())}',
    queryParams: {if (_self.page != 1) 'page': _self.page.toString()},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}
