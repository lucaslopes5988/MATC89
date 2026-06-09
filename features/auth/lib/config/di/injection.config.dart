// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:core/core.dart' as _i494;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/auth_repository.dart' as _i841;
import '../../data/datasource/firebase/firebase_auth_data_source.dart' as _i357;
import '../../domain/repository/i_auth_repository.dart' as _i437;
import '../../domain/usecase/auth_usecases.dart' as _i255;
import '../../presentation/login/bloc/login_cubit.dart' as _i118;
import 'auth_external_module.dart' as _i358;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt initAuthGetIt({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final authExternalModule = _$AuthExternalModule();
    gh.lazySingleton<_i59.FirebaseAuth>(
      () => authExternalModule.provideFirebaseAuth(),
    );
    gh.lazySingleton<_i116.GoogleSignIn>(
      () => authExternalModule.provideGoogleSignIn(),
    );
    gh.factory<_i357.FirebaseAuthDataSource>(
      () => _i357.FirebaseAuthDataSource(
        gh<_i59.FirebaseAuth>(),
        gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.factory<_i437.IAuthRepository>(
      () => _i841.AuthRepository(gh<_i357.FirebaseAuthDataSource>()),
    );
    gh.factory<_i494.ITokenGetter>(
      () => _i841.AuthTokenGetter(gh<_i437.IAuthRepository>()),
    );
    gh.factory<_i255.SignInWithGoogleUseCase>(
      () => _i255.SignInWithGoogleUseCase(gh<_i437.IAuthRepository>()),
    );
    gh.factory<_i255.SignOutUseCase>(
      () => _i255.SignOutUseCase(gh<_i437.IAuthRepository>()),
    );
    gh.factory<_i255.GetCurrentUserUseCase>(
      () => _i255.GetCurrentUserUseCase(gh<_i437.IAuthRepository>()),
    );
    gh.factory<_i255.ObserveAuthStateUseCase>(
      () => _i255.ObserveAuthStateUseCase(gh<_i437.IAuthRepository>()),
    );
    gh.factory<_i118.LoginCubit>(
      () => _i118.LoginCubit(gh<_i255.SignInWithGoogleUseCase>()),
    );
    return this;
  }
}

class _$AuthExternalModule extends _i358.AuthExternalModule {}
