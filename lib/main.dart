import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'di/injection.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  runApp(const PlayceApp());
}

class PlayceApp extends StatelessWidget {
  const PlayceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Playce',
      debugShowCheckedModeBanner: false,
      theme: PlayceTheme.light(),
      navigatorKey: AppNavigator.key,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRoutes.authGate,
    );
  }
}
