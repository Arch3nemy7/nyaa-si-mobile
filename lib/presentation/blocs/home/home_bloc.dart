import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/nyaa_torrent_entities.dart';
import '../../../domain/usecases/fetch_torrents_usecase.dart';
import '../../../domain/usecases/download_torrent_usecase.dart';
import '../../dependency_injection.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchTorrentsUseCase _fetchTorrentsUseCase;
  final DownloadTorrentUseCase _downloadTorrentUseCase;

  final Map<String, bool> _downloadingTorrents = <String, bool>{};

  static const int _defaultPage = 1;
  static const int _defaultPageSize = 20;
  static const String _defaultFilterStatus = '0';
  static const String _defaultFilterCategory = '0_0';
  static const String _defaultSortField = 'id';
  static const String _defaultSortOrder = 'desc';
  static const String _defaultSearchQuery = '';

  HomeBloc()
    : _fetchTorrentsUseCase = serviceLocator<FetchTorrentsUseCase>(),
      _downloadTorrentUseCase = serviceLocator<DownloadTorrentUseCase>(),
      super(HomeInitial()) {
    on<FetchTorrentsEvent>(_onFetchTorrents);
    on<RefreshTorrentsEvent>(_onRefreshTorrents);
    on<DownloadTorrentEvent>(_onDownloadTorrent);
  }

  bool isTorrentDownloading(String torrentId) =>
      _downloadingTorrents[torrentId] ?? false;

  Future<void> _onFetchTorrents(
    FetchTorrentsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(TorrentsLoadingState());
    await _loadTorrents(emit);
  }

  Future<void> _onRefreshTorrents(
    RefreshTorrentsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(TorrentsLoadingState());
    await _loadTorrents(emit);
  }

  Future<void> _onDownloadTorrent(
    DownloadTorrentEvent event,
    Emitter<HomeState> emit,
  ) async {
    final String torrentId = event.torrent.id;

    if (_downloadingTorrents[torrentId] == true) return;

    _downloadingTorrents[torrentId] = true;
    emit(_updateCurrentStateWithDownloading());

    try {
      final String filePath = await _downloadTorrentUseCase.call(
        torrentId: torrentId,
      );

      _downloadingTorrents[torrentId] = false;
      emit(
        TorrentDownloadedState(
          torrentId: torrentId,
          filePath: filePath,
          torrents: _getCurrentTorrents(),
          downloadingTorrents: Map<String, bool>.from(_downloadingTorrents),
        ),
      );

      if (!emit.isDone) {
        emit(_createLoadedState(_getCurrentTorrents()));
      }
    } catch (e) {
      _downloadingTorrents[torrentId] = false;
      emit(
        TorrentDownloadErrorState(
          torrentId: torrentId,
          error: e.toString(),
          torrents: _getCurrentTorrents(),
          downloadingTorrents: Map<String, bool>.from(_downloadingTorrents),
        ),
      );

      if (!emit.isDone) {
        emit(_createLoadedState(_getCurrentTorrents()));
      }
    }
  }

  Future<void> _loadTorrents(Emitter<HomeState> emit) async {
    try {
      final List<NyaaTorrentEntity> torrents = await _fetchTorrentsUseCase.call(
        page: _defaultPage,
        pageSize: _defaultPageSize,
        searchQuery: _defaultSearchQuery,
        filterStatus: _defaultFilterStatus,
        filterCategory: _defaultFilterCategory,
        sortField: _defaultSortField,
        sortOrder: _defaultSortOrder,
      );

      emit(_createLoadedState(torrents));
    } catch (e) {
      emit(TorrentsErrorState(error: e.toString()));
    }
  }

  TorrentsLoadedState _createLoadedState(List<NyaaTorrentEntity> torrents) =>
      TorrentsLoadedState(
        torrents: torrents,
        page: _defaultPage,
        pageSize: _defaultPageSize,
        hasReachedMax: torrents.length < _defaultPageSize,
        filterStatus: _defaultFilterStatus,
        sortField: _defaultSortField,
        sortOrder: _defaultSortOrder,
        searchQuery: _defaultSearchQuery,
        downloadingTorrents: Map<String, bool>.from(_downloadingTorrents),
      );

  HomeState _updateCurrentStateWithDownloading() {
    final List<NyaaTorrentEntity> currentTorrents = _getCurrentTorrents();
    if (currentTorrents.isEmpty) {
      return TorrentsLoadingState();
    }
    return _createLoadedState(currentTorrents);
  }

  List<NyaaTorrentEntity> _getCurrentTorrents() {
    if (state is TorrentsLoadedState) {
      return (state as TorrentsLoadedState).torrents;
    } else if (state is TorrentDownloadedState) {
      return (state as TorrentDownloadedState).torrents;
    } else if (state is TorrentDownloadErrorState) {
      return (state as TorrentDownloadErrorState).torrents;
    }
    return <NyaaTorrentEntity>[];
  }
}
