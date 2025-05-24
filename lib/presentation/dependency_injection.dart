import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:nyaa_si_mobile/core/services/network_service/api_config.dart';
import 'package:nyaa_si_mobile/core/services/network_service/dio_client.dart';
import 'package:nyaa_si_mobile/data/providers/remote_torrents_provider.dart';
import 'package:nyaa_si_mobile/data/repositories/torrents_repositories_impl.dart';
import 'package:nyaa_si_mobile/domain/repositories/torrents_repository.dart';
import 'package:nyaa_si_mobile/domain/usecases/fetch_torrents_usecase.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  try {
    await _initializeNetwork();
    await _initializeSharedPreferences();
    await _initializeProviders();
    await _initializeRepositories();
    await _initializeUseCases();
  } catch (e) {
    throw DependencyInitializationException(
      'Failed to initialize dependencies: $e',
    );
  }
}

Future<void> _initializeNetwork() async {
  serviceLocator
    ..registerLazySingleton(Dio.new)
    ..registerLazySingleton<ApiConfig>(() {
      if (kReleaseMode) {
        return ApiConfig.production();
      } else {
        return ApiConfig.development();
      }
    })
    ..registerLazySingleton(
      () => DioClient(
        dio: serviceLocator<Dio>(),
        apiConfig: serviceLocator<ApiConfig>(),
      ),
    );
}

Future<void> _initializeSharedPreferences() async {}

Future<void> _initializeProviders() async {
  serviceLocator.registerFactory<RemoteTorrentsProvider>(
    () => RemoteTorrentsProvider(serviceLocator<DioClient>()),
  );
}

Future<void> _initializeRepositories() async {
  serviceLocator.registerFactory<TorrentsRepository>(
    () => TorrentsRepositoryImpl(serviceLocator<RemoteTorrentsProvider>()),
  );
}

Future<void> _initializeUseCases() async {
  serviceLocator.registerFactory<FetchTorrentsUseCase>(
    () => FetchTorrentsUseCase(serviceLocator<TorrentsRepository>()),
  );
}

class DependencyInitializationException implements Exception {
  DependencyInitializationException(this.message);
  final String message;

  @override
  String toString() => message;
}
