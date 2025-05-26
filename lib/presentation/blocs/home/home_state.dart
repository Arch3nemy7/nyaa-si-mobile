part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => <Object?>[];
}

class HomeInitial extends HomeState {}

class TorrentsLoadingState extends HomeState {}

class TorrentsLoadedState extends HomeState {
  final List<NyaaTorrentEntity> torrents;
  final int page;
  final int pageSize;
  final bool hasReachedMax;
  final String filterStatus;
  final String? sortField;
  final String? sortOrder;
  final String? searchQuery;
  final Map<String, bool> downloadingTorrents;

  const TorrentsLoadedState({
    required this.torrents,
    required this.page,
    required this.pageSize,
    required this.hasReachedMax,
    required this.filterStatus,
    this.sortField,
    this.sortOrder,
    this.searchQuery,
    this.downloadingTorrents = const <String, bool>{},
  });

  TorrentsLoadedState copyWith({
    List<NyaaTorrentEntity>? torrents,
    int? page,
    int? pageSize,
    bool? hasReachedMax,
    String? filterStatus,
    String? sortField,
    String? sortOrder,
    String? searchQuery,
    Map<String, bool>? downloadingTorrents,
  }) => TorrentsLoadedState(
    torrents: torrents ?? this.torrents,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    filterStatus: filterStatus ?? this.filterStatus,
    sortField: sortField ?? this.sortField,
    sortOrder: sortOrder ?? this.sortOrder,
    searchQuery: searchQuery ?? this.searchQuery,
    downloadingTorrents: downloadingTorrents ?? this.downloadingTorrents,
  );

  @override
  List<Object?> get props => <Object?>[
    torrents,
    page,
    pageSize,
    hasReachedMax,
    filterStatus,
    sortField,
    sortOrder,
    searchQuery,
    downloadingTorrents,
  ];
}

class TorrentsErrorState extends HomeState {
  final String error;

  const TorrentsErrorState({required this.error});

  @override
  List<Object> get props => <Object>[error];
}

class TorrentDownloadedState extends HomeState {
  final String torrentId;
  final String filePath;
  final List<NyaaTorrentEntity> torrents;
  final Map<String, bool> downloadingTorrents;

  const TorrentDownloadedState({
    required this.torrentId,
    required this.filePath,
    required this.torrents,
    this.downloadingTorrents = const <String, bool>{},
  });

  @override
  List<Object> get props => <Object>[
    torrentId,
    filePath,
    torrents,
    downloadingTorrents,
  ];
}

class TorrentDownloadErrorState extends HomeState {
  final String torrentId;
  final String error;
  final List<NyaaTorrentEntity> torrents;
  final Map<String, bool> downloadingTorrents;

  const TorrentDownloadErrorState({
    required this.torrentId,
    required this.error,
    required this.torrents,
    this.downloadingTorrents = const <String, bool>{},
  });

  @override
  List<Object> get props => <Object>[
    torrentId,
    error,
    torrents,
    downloadingTorrents,
  ];
}
