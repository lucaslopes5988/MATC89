import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

@InjectableInit(
  initializerName: 'initEventsGetIt',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureEventsDependencies(GetIt getIt) async {
  getIt.initEventsGetIt();
}
