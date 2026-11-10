/// App và API phục vụ thực hành thư viện go_router.
library package_go_route;

export 'app.dart' show PackageGoRouteApp, runPackageGoRouteApp;
export 'src/routing/demo_navigation.dart'
    show DemoNavigation, safeReturnLocation;
export 'src/routing/extra_codec.dart' show DemoExtraCodec, ProductPreview;
export 'src/routing/route_names.dart' show RouteNames;
export 'src/routing/typed_routes.dart' show TypedBookRoute;
