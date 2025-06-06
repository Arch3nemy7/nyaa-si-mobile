import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../core/services/network_service/api_config.dart';
import '../core/services/network_service/dio_client.dart';
import '../data/providers/local/interfaces/i_downloaded_torrent_provider.dart';
import '../data/providers/local/implements/local_downloaded_torrent_provider.dart';
import '../data/providers/remote/interfaces/i_torrents_provider.dart';
import '../data/providers/remote/implements/remote_torrents_provider.dart';
import '../data/repositories/torrents_repository_impl.dart';
import '../data/repositories/downloaded_torrent_repository_impl.dart';
import '../domain/repositories/torrents_repository.dart';
import '../domain/repositories/downloaded_torrent_repository.dart';
import '../domain/usecases/delete_downloaded_torrent_usecase.dart';
import '../domain/usecases/delete_release_group_usecase.dart';
import '../domain/usecases/download_torrent_usecase.dart';
import '../domain/usecases/fetch_torrents_usecase.dart';
import '../domain/usecases/get_all_downloaded_torrents_usecase.dart';
import '../domain/usecases/get_grouped_torrent_usecase.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  try {
    await _initializeNetwork();
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

Future<void> _initializeProviders() async {
  serviceLocator
    ..registerFactory<IRemoteTorrentsProvider>(
      () => RemoteTorrentsProviderImpl(serviceLocator<DioClient>()),
    )
    ..registerLazySingleton<IDownloadedTorrentProvider>(
      () => DownloadedTorrentProviderImpl(),
    );
}

Future<void> _initializeRepositories() async {
  serviceLocator
    ..registerFactory<TorrentsRepository>(
      () => TorrentsRepositoryImpl(serviceLocator<IRemoteTorrentsProvider>()),
    )
    ..registerLazySingleton<DownloadedTorrentRepository>(
      () => DownloadedTorrentRepositoryImpl(
        localDataSource: serviceLocator<IDownloadedTorrentProvider>(),
      ),
    );
}

Future<void> _initializeUseCases() async {
  serviceLocator
    ..registerFactory<FetchTorrentsUseCase>(
      () => FetchTorrentsUseCase(serviceLocator<TorrentsRepository>()),
    )
    ..registerFactory<DownloadTorrentUsecase>(
      () => DownloadTorrentUsecase(serviceLocator<TorrentsRepository>()),
    )
    ..registerLazySingleton(
      () => GetAllDownloadedTorrentsUsecase(
        serviceLocator<DownloadedTorrentRepository>(),
      ),
    )
    ..registerLazySingleton(
      () => GetGroupedTorrentsUsecase(
        serviceLocator<DownloadedTorrentRepository>(),
      ),
    )
    ..registerLazySingleton(
      () => DeleteTorrentUsecase(serviceLocator<DownloadedTorrentRepository>()),
    )
    ..registerLazySingleton(
      () => DeleteReleaseGroupUsecase(
        serviceLocator<DownloadedTorrentRepository>(),
      ),
    );
}

class DependencyInitializationException implements Exception {
  DependencyInitializationException(this.message);
  final String message;

  @override
  String toString() => message;
}
