import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:core/config/app_env.dart';
import 'package:core/network/i_token_getter.dart';

const unloggedAreaDio = Named('UnloggedAreaDio');
const loggedAreaDio = Named('LoggedAreaDio');

@module
abstract class NetworkModule {
  @unloggedAreaDio
  @lazySingleton
  Dio provideUnloggedDio() => _createDio();

  @loggedAreaDio
  @lazySingleton
  Dio provideLoggedDio(ITokenGetter tokenGetter) {
    final dio = _createDio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenGetter.getIdToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
    return dio;
  }

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppEnv.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return dio;
  }
}
