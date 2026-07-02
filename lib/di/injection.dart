import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:events/events.dart';
import 'package:get_it/get_it.dart';
import 'package:profile/profile.dart';

Future<void> configureDependencies() async {
  final getIt = GetIt.instance;

  await configureCoreDependencies(getIt);
  await configureAuthDependencies(getIt);
  await configureEventsDependencies(getIt);
  await configureProfileDependencies(getIt);
}
