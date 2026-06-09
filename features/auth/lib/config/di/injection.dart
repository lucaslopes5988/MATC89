import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

@InjectableInit(
  initializerName: 'initAuthGetIt',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureAuthDependencies(GetIt getIt) async {
  getIt.initAuthGetIt();
}
