import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

@InjectableInit(
  initializerName: 'initCoreGetIt',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureCoreDependencies(GetIt getIt) async {
  await getIt.initCoreGetIt();
}
