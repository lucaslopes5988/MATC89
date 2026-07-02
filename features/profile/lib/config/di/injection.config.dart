// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/datasource/firebase/profile_firestore_data_source.dart'
    as _i43;
import '../../data/profile_repository.dart' as _i1016;
import '../../domain/repository/i_profile_repository.dart' as _i444;
import '../../domain/usecase/profile_usecases.dart' as _i906;
import '../../presentation/profile/bloc/profile_cubit.dart' as _i738;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt initProfileGetIt({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i43.ProfileFirestoreDataSource>(
      () => _i43.ProfileFirestoreDataSource(gh<_i974.FirebaseFirestore>()),
    );
    gh.factory<_i444.IProfileRepository>(
      () => _i1016.ProfileRepository(gh<_i43.ProfileFirestoreDataSource>()),
    );
    gh.factory<_i906.GetProfileUseCase>(
      () => _i906.GetProfileUseCase(gh<_i444.IProfileRepository>()),
    );
    gh.factory<_i906.UpdateGenderIdentityUseCase>(
      () => _i906.UpdateGenderIdentityUseCase(gh<_i444.IProfileRepository>()),
    );
    gh.factory<_i738.ProfileCubit>(
      () => _i738.ProfileCubit(
        gh<_i906.GetProfileUseCase>(),
        gh<_i906.UpdateGenderIdentityUseCase>(),
      ),
    );
    return this;
  }
}
