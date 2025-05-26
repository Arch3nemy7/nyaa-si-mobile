part of 'torrent_list_bloc.dart';

sealed class TorrentListState extends Equatable {
  const TorrentListState();

  @override
  List<Object?> get props => <Object?>[];
}

class TorrentListInitial extends TorrentListState {}

class TorrentListLoadingState extends TorrentListState {}

class TorrentListLoadedState extends TorrentListState {
  final List<NyaaTorrentEntity> torrents;
  final int page;
  final int pageSize;
  final bool hasReachedMax;
  final String? searchQuery;
  final String? filterStatus;
  final String? filterCategory;
  final String? sortField;
  final String? sortOrder;

  const TorrentListLoadedState({
    required this.torrents,
    required this.page,
    required this.pageSize,
    required this.hasReachedMax,
    this.searchQuery,
    this.filterCategory,
    this.filterStatus,
    this.sortField,
    this.sortOrder,
  });

  TorrentListLoadedState copyWith({
    List<NyaaTorrentEntity>? torrents,
    int? page,
    int? pageSize,
    bool? hasReachedMax,
    String? searchQuery,
    String? filterStatus,
    String? filterCategory,
    String? sortField,
    String? sortOrder,
    Map<String, bool>? downloadingTorrents,
  }) => TorrentListLoadedState(
    torrents: torrents ?? this.torrents,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    searchQuery: searchQuery ?? this.searchQuery,
    filterStatus: filterStatus ?? this.filterStatus,
    filterCategory: filterCategory ?? this.filterCategory,
    sortField: sortField ?? this.sortField,
    sortOrder: sortOrder ?? this.sortOrder,
  );

  @override
  List<Object?> get props => <Object?>[
    torrents,
    page,
    pageSize,
    hasReachedMax,
    searchQuery,
    filterStatus,
    filterCategory,
    sortField,
    sortOrder,
  ];
}

class TorrentListErrorState extends TorrentListState {
  final String error;

  const TorrentListErrorState({required this.error});

  @override
  List<Object> get props => <Object>[error];
}

