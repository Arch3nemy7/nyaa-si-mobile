import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/nyaa_torrent_entities.dart';
import '../../../domain/usecases/fetch_torrents_usecase.dart';
import '../../dependency_injection.dart';

part 'torrent_list_event.dart';
part 'torrent_list_state.dart';

class TorrentListBloc extends Bloc<HomeEvent, TorrentListState> {
  final FetchTorrentsUseCase _fetchTorrentsUseCase;

  static const int _defaultPage = 1;
  static const int _defaultPageSize = 20;
  static const String _defaultFilterStatus = '0';
  static const String _defaultFilterCategory = '0_0';
  static const String _defaultSortField = 'id';
  static const String _defaultSortOrder = 'desc';
  static const String _defaultSearchQuery = '';

  TorrentListBloc()
    : _fetchTorrentsUseCase = serviceLocator<FetchTorrentsUseCase>(),
      super(TorrentListInitial()) {
    on<FetchTorrentListEvent>(_onFetchTorrents);
    on<RefreshTorrentListEvent>(_onRefreshTorrents);
  }

  Future<void> _onFetchTorrents(
    FetchTorrentListEvent event,
    Emitter<TorrentListState> emit,
  ) async {
    emit(TorrentListLoadingState());

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

      emit(
        TorrentListLoadedState(
          torrents: torrents,
          page: _defaultPage,
          pageSize: _defaultPageSize,
          hasReachedMax: torrents.length < _defaultPageSize,
          filterStatus: _defaultFilterStatus,
          sortField: _defaultSortField,
          sortOrder: _defaultSortOrder,
          searchQuery: _defaultSearchQuery,
        ),
      );
    } catch (e) {
      emit(TorrentListErrorState(error: e.toString()));
    }
  }

  Future<void> _onRefreshTorrents(
    RefreshTorrentListEvent event,
    Emitter<TorrentListState> emit,
  ) async {
    final TorrentListLoadedState currentState = state as TorrentListLoadedState;
    
    emit(TorrentListLoadingState());

    try {
      final List<NyaaTorrentEntity> torrents = await _fetchTorrentsUseCase.call(
        page: currentState.page,
        pageSize: currentState.pageSize,
        searchQuery: currentState.searchQuery ?? _defaultSearchQuery,
        filterStatus: currentState.filterStatus ?? _defaultFilterStatus,
        filterCategory: currentState.filterCategory ?? _defaultFilterCategory,
        sortField: currentState.sortField ?? _defaultSortField,
        sortOrder: currentState.sortOrder ?? _defaultSortOrder,
      );

      emit(
        TorrentListLoadedState(
          torrents: torrents,
          page: _defaultPage,
          pageSize: _defaultPageSize,
          hasReachedMax: torrents.length < _defaultPageSize,
          filterStatus: _defaultFilterStatus,
          sortField: _defaultSortField,
          sortOrder: _defaultSortOrder,
          searchQuery: _defaultSearchQuery,
        ),
      );
    } catch (e) {
      emit(TorrentListErrorState(error: e.toString()));
    }
  }
}
