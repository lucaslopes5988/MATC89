// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_core/firebase_core.dart' as _i982;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'package:core/network/i_token_getter.dart' as _i1000;

import 'firebase_module.dart' as _i616;
import 'network_module.dart' as _i567;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> initCoreGetIt({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final firebaseModule = _$FirebaseModule();
    final networkModule = _$NetworkModule();
    await gh.factoryAsync<_i982.FirebaseApp>(
      () => firebaseModule.provideFirebaseApp(),
      preResolve: true,
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.provideUnloggedDio(),
      instanceName: 'UnloggedAreaDio',
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.provideLoggedDio(gh<_i1000.ITokenGetter>()),
      instanceName: 'LoggedAreaDio',
    );
    return this;
  }
}

class _$FirebaseModule extends _i616.FirebaseModule {}

class _$NetworkModule extends _i567.NetworkModule {}
