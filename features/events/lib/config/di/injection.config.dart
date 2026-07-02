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

import '../../data/datasource/firebase/events_firestore_data_source.dart'
    as _i992;
import '../../data/events_repository.dart' as _i405;
import '../../domain/repository/i_events_repository.dart' as _i616;
import '../../domain/usecase/events_usecases.dart' as _i74;
import '../../presentation/create/bloc/create_event_cubit.dart' as _i707;
import '../../presentation/details/bloc/event_details_cubit.dart' as _i607;
import '../../presentation/explore/bloc/explore_cubit.dart' as _i858;
import '../../presentation/map/bloc/map_events_cubit.dart' as _i945;
import 'events_external_module.dart' as _i923;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt initEventsGetIt({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final eventsExternalModule = _$EventsExternalModule();
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => eventsExternalModule.provideFirestore(),
    );
    gh.factory<_i992.EventsFirestoreDataSource>(
      () => _i992.EventsFirestoreDataSource(gh<_i974.FirebaseFirestore>()),
    );
    gh.factory<_i616.IEventsRepository>(
      () => _i405.EventsRepository(gh<_i992.EventsFirestoreDataSource>()),
    );
    gh.factory<_i74.GetUpcomingEventsUseCase>(
      () => _i74.GetUpcomingEventsUseCase(gh<_i616.IEventsRepository>()),
    );
    gh.factory<_i74.GetEventByIdUseCase>(
      () => _i74.GetEventByIdUseCase(gh<_i616.IEventsRepository>()),
    );
    gh.factory<_i74.JoinEventUseCase>(
      () => _i74.JoinEventUseCase(gh<_i616.IEventsRepository>()),
    );
    gh.factory<_i74.LeaveEventUseCase>(
      () => _i74.LeaveEventUseCase(gh<_i616.IEventsRepository>()),
    );
    gh.factory<_i74.CreateEventUseCase>(
      () => _i74.CreateEventUseCase(gh<_i616.IEventsRepository>()),
    );
    gh.factory<_i858.ExploreCubit>(
      () => _i858.ExploreCubit(gh<_i74.GetUpcomingEventsUseCase>()),
    );
    gh.factory<_i945.MapEventsCubit>(
      () => _i945.MapEventsCubit(gh<_i74.GetUpcomingEventsUseCase>()),
    );
    gh.factory<_i607.EventDetailsCubit>(
      () => _i607.EventDetailsCubit(
        gh<_i74.GetEventByIdUseCase>(),
        gh<_i74.JoinEventUseCase>(),
        gh<_i74.LeaveEventUseCase>(),
      ),
    );
    gh.factory<_i707.CreateEventCubit>(
      () => _i707.CreateEventCubit(gh<_i74.CreateEventUseCase>()),
    );
    return this;
  }
}

class _$EventsExternalModule extends _i923.EventsExternalModule {}
