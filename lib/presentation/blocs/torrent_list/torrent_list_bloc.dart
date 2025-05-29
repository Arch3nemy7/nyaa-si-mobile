import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/nyaa_torrent_entities.dart';
import '../../../domain/usecases/fetch_torrents_usecase.dart';
import '../../dependency_injection.dart';

part 'torrent_list_event.dart';
part 'torrent_list_state.dart';

class TorrentListBloc extends Bloc<TorrentListEvent, TorrentListState> {
  final FetchTorrentsUseCase _fetchTorrentsUseCase;

  static const int _defaultPage = 1;
  static const int _defaultPageSize = 20;
  static const String _defaultSearchQuery = '';
  static const String _defaultFilterStatus = '0';
  static const String _defaultFilterCategory = '0_0';
  static const String _defaultSortField = 'id';
  static const String _defaultSortOrder = 'desc';

  TorrentListBloc()
    : _fetchTorrentsUseCase = serviceLocator<FetchTorrentsUseCase>(),
      super(TorrentListInitial()) {
    on<FetchTorrentListEvent>(_onFetchTorrents);
    on<RefreshTorrentListEvent>(_onRefreshTorrents);
    on<LoadMoreTorrentsEvent>(_onLoadMoreTorrents);
    on<SearchTorrentEvent>(_onSearchTorrents);
    on<SortTorrentEvent>(_onSortTorrents);
    on<FilterTorrentStatusEvent>(_onFilterTorrentsStatus);
    on<FilterTorrentCategoryEvent>(_onFilterTorrentsCategory);
  }

  Future<void> _onFetchTorrents(
    FetchTorrentListEvent event,
    Emitter<TorrentListState> emit,
  ) async {
    emit(const TorrentListLoadingState());

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
          filterCategory: _defaultFilterCategory,
          sortField: _defaultSortField,
          sortOrder: _defaultSortOrder,
          searchQuery: _defaultSearchQuery,
        ),
      );
    } catch (e) {
      emit(TorrentListErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshTorrents(
    RefreshTorrentListEvent event,
    Emitter<TorrentListState> emit,
  ) async {
    if (state is! TorrentListLoadedState) {
      add(const FetchTorrentListEvent());
      return;
    }

    final TorrentListLoadedState currentState = state as TorrentListLoadedState;

    try {
      final List<NyaaTorrentEntity> torrents = await _fetchTorrentsUseCase.call(
        page: _defaultPage,
        pageSize: currentState.pageSize,
        searchQuery: currentState.searchQuery ?? _defaultSearchQuery,
        filterStatus: currentState.filterStatus ?? _defaultFilterStatus,
        filterCategory: currentState.filterCategory ?? _defaultFilterCategory,
        sortField: currentState.sortField ?? _defaultSortField,
        sortOrder: currentState.sortOrder ?? _defaultSortOrder,
      );

      emit(
        currentState.copyWith(
          torrents: torrents,
          page: _defaultPage,
          hasReachedMax: torrents.length < currentState.pageSize,
        ),
      );
    } catch (e) {
      emit(TorrentListErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMoreTorrents(
    LoadMoreTorrentsEvent event,
    Emitter<TorrentListState> emit,
  ) async {
    if (state is! TorrentListLoadedState) return;

    final TorrentListLoadedState currentState = state as TorrentListLoadedState;

    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final List<NyaaTorrentEntity> moreTorrents = await _fetchTorrentsUseCase
          .call(
            page: currentState.page + 1,
            pageSize: currentState.pageSize,
            searchQuery: currentState.searchQuery ?? _defaultSearchQuery,
            filterStatus: currentState.filterStatus ?? _defaultFilterStatus,
            filterCategory:
                currentState.filterCategory ?? _defaultFilterCategory,
            sortField: currentState.sortField ?? _defaultSortField,
            sortOrder: currentState.sortOrder ?? _defaultSortOrder,
          );

      final List<NyaaTorrentEntity> allTorrents = <NyaaTorrentEntity>[
        ...currentState.torrents,
        ...moreTorrents,
      ];

      emit(
        currentState.copyWith(
          torrents: allTorrents,
          page: currentState.page + 1,
          hasReachedMax: moreTorrents.length < currentState.pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onSearchTorrents(
    SearchTorrentEvent event,
    Emitter<TorrentListState> emit,
  ) async {
    if (state is! TorrentListLoadedState) {
      add(const FetchTorrentListEvent());
      return;
    }

    final TorrentListLoadedState currentState = state as TorrentListLoadedState;

    if (currentState.searchQuery == event.query) {
      return;
    }

    emit(
      TorrentListLoadingState(
        searchQuery: event.query,
        filterCategory: currentState.filterCategory,
        filterStatus: currentState.filterStatus,
        sortField: currentState.sortField,
        sortOrder: currentState.sortOrder,
      ),
    );

    try {
      final List<NyaaTorrentEntity> torrents = await _fetchTorrentsUseCase.call(
        page: _defaultPage,
        pageSize: currentState.pageSize,
        searchQuery: event.query,
        filterStatus: currentState.filterStatus ?? _defaultFilterStatus,
        filterCategory: currentState.filterCategory ?? _defaultFilterCategory,
        sortField: currentState.sortField ?? _defaultSortField,
        sortOrder: currentState.sortOrder ?? _defaultSortOrder,
      );

      emit(
        currentState.copyWith(
          torrents: torrents,
          page: _defaultPage,
          searchQuery: event.query,
          hasReachedMax: torrents.length < currentState.pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(TorrentListErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _onSortTorrents(
    SortTorrentEvent event,
    Emitter<TorrentListState> emit,
  ) async {
    if (state is! TorrentListLoadedState) {
      add(const FetchTorrentListEvent());
      return;
    }

    final TorrentListLoadedState currentState = state as TorrentListLoadedState;

    emit(
      TorrentListLoadingState(
        searchQuery: currentState.searchQuery,
        filterCategory: currentState.filterCategory,
        filterStatus: currentState.filterStatus,
        sortField: event.sortField,
        sortOrder: event.sortOrder,
      ),
    );

    try {
      final List<NyaaTorrentEntity> torrents = await _fetchTorrentsUseCase.call(
        page: _defaultPage,
        pageSize: currentState.pageSize,
        searchQuery: currentState.searchQuery ?? _defaultSearchQuery,
        filterStatus: currentState.filterStatus ?? _defaultFilterStatus,
        filterCategory: currentState.filterCategory ?? _defaultFilterCategory,
        sortField: event.sortField,
        sortOrder: event.sortOrder,
      );

      emit(
        currentState.copyWith(
          torrents: torrents,
          page: _defaultPage,
          sortField: event.sortField,
          sortOrder: event.sortOrder,
          hasReachedMax: torrents.length < currentState.pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(TorrentListErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _onFilterTorrentsStatus(
    FilterTorrentStatusEvent event,
    Emitter<TorrentListState> emit,
  ) async {
    if (state is! TorrentListLoadedState) {
      add(const FetchTorrentListEvent());
      return;
    }

    final TorrentListLoadedState currentState = state as TorrentListLoadedState;

    if (currentState.filterStatus == event.filterStatus) {
      return;
    }

    emit(
      TorrentListLoadingState(
        searchQuery: currentState.searchQuery,
        filterCategory: currentState.filterCategory,
        filterStatus: event.filterStatus,
        sortField: currentState.sortField,
        sortOrder: currentState.sortOrder,
      ),
    );

    try {
      final List<NyaaTorrentEntity> torrents = await _fetchTorrentsUseCase.call(
        page: _defaultPage,
        pageSize: currentState.pageSize,
        searchQuery: currentState.searchQuery ?? _defaultSearchQuery,
        filterStatus: event.filterStatus,
        filterCategory: currentState.filterCategory ?? _defaultFilterCategory,
        sortField: currentState.sortField ?? _defaultSortField,
        sortOrder: currentState.sortOrder ?? _defaultSortOrder,
      );

      emit(
        currentState.copyWith(
          torrents: torrents,
          page: _defaultPage,
          filterStatus: event.filterStatus,
          filterCategory: currentState.filterCategory ?? _defaultFilterCategory,
          hasReachedMax: torrents.length < currentState.pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(TorrentListErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _onFilterTorrentsCategory(
    FilterTorrentCategoryEvent event,
    Emitter<TorrentListState> emit,
  ) async {
    if (state is! TorrentListLoadedState) {
      add(const FetchTorrentListEvent());
      return;
    }

    final TorrentListLoadedState currentState = state as TorrentListLoadedState;

    if (currentState.filterCategory == event.filterCategory) {
      return;
    }

    emit(
      TorrentListLoadingState(
        searchQuery: currentState.searchQuery,
        filterCategory: event.filterCategory,
        filterStatus: currentState.filterStatus,
        sortField: currentState.sortField,
        sortOrder: currentState.sortOrder,
      ),
    );

    try {
      final List<NyaaTorrentEntity> torrents = await _fetchTorrentsUseCase.call(
        page: _defaultPage,
        pageSize: currentState.pageSize,
        searchQuery: currentState.searchQuery ?? _defaultSearchQuery,
        filterStatus: currentState.filterStatus ?? _defaultFilterStatus,
        filterCategory: event.filterCategory,
        sortField: currentState.sortField ?? _defaultSortField,
        sortOrder: currentState.sortOrder ?? _defaultSortOrder,
      );

      emit(
        currentState.copyWith(
          torrents: torrents,
          page: _defaultPage,
          filterCategory: event.filterCategory,
          hasReachedMax: torrents.length < currentState.pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(TorrentListErrorState(errorMessage: e.toString()));
    }
  }
}
