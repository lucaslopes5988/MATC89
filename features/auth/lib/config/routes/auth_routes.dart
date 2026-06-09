import 'package:flutter/material.dart';

import '../../presentation/login/widget/login_page.dart';

typedef RouteBuilder = Route<dynamic> Function(RouteSettings settings);

abstract final class AuthRoutes {
  static const login = '/login';

  static Map<String, RouteBuilder> get routes => {
    login: (settings) => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const LoginPage(),
    ),
  };
}
