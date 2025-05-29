part of 'torrent_list_bloc.dart';

sealed class TorrentListState extends Equatable {
  final String? searchQuery;
  final String? filterStatus;
  final String? filterCategory;
  final String? sortField;
  final String? sortOrder;

  const TorrentListState({
    this.searchQuery,
    this.filterStatus,
    this.filterCategory,
    this.sortField,
    this.sortOrder,
  });

  @override
  List<Object?> get props => <Object?>[
    searchQuery,
    filterStatus,
    filterCategory,
    sortField,
    sortOrder,
  ];
}

class TorrentListInitial extends TorrentListState {}

class TorrentListLoadingState extends TorrentListState {
  const TorrentListLoadingState({
    super.searchQuery,
    super.filterCategory,
    super.filterStatus,
    super.sortField,
    super.sortOrder,
  });
}

class TorrentListLoadedState extends TorrentListState {
  final List<NyaaTorrentEntity> torrents;
  final int page;
  final int pageSize;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const TorrentListLoadedState({
    required this.torrents,
    required this.page,
    required this.pageSize,
    this.hasReachedMax = false,
    super.searchQuery,
    super.filterCategory,
    super.filterStatus,
    super.sortField,
    super.sortOrder,
    this.isLoadingMore = false,
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
    bool? isLoadingMore,
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
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
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
    isLoadingMore,
  ];
}

class TorrentListErrorState extends TorrentListState {
  final String errorMessage;

  const TorrentListErrorState({
    required this.errorMessage,
    super.searchQuery,
    super.filterCategory,
    super.filterStatus,
    super.sortField,
    super.sortOrder,
  });

  @override
  List<Object?> get props => <Object?>[errorMessage, ...super.props];
}
