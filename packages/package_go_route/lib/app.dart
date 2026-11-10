import 'package:flutter/material.dart';

import 'src/routing/demo_navigation.dart';

void runPackageGoRouteApp() => runApp(const PackageGoRouteApp());

class PackageGoRouteApp extends StatefulWidget {
  const PackageGoRouteApp({super.key, this.navigation});

  /// Cho phép test inject router với initialLocation để mô phỏng deep link.
  /// Nếu truyền object từ ngoài, bên tạo object chịu trách nhiệm dispose nó.
  final DemoNavigation? navigation;

  @override
  State<PackageGoRouteApp> createState() => _PackageGoRouteAppState();
}

class _PackageGoRouteAppState extends State<PackageGoRouteApp> {
  late final bool _ownsNavigation;
  late final DemoNavigation _navigation;

  @override
  void initState() {
    super.initState();
    _ownsNavigation = widget.navigation == null;
    _navigation = widget.navigation ?? DemoNavigation();
  }

  @override
  void dispose() {
    if (_ownsNavigation) _navigation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Thực hành go_router',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    // Router-based app dùng routerConfig; không trộn home/routes/onGenerateRoute
    // của MaterialApp kiểu Navigator 1.0 vào constructor này.
    routerConfig: _navigation.router,
    restorationScopeId: 'go-route-learning-app',
  );
}
