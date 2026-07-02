import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

@InjectableInit(
  initializerName: 'initProfileGetIt',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureProfileDependencies(GetIt getIt) async {
  getIt.initProfileGetIt();
}
