part of 'torrent_list_bloc.dart';

sealed class TorrentListEvent extends Equatable {
  const TorrentListEvent();

  @override
  List<Object?> get props => <Object>[];
}

class FetchTorrentListEvent extends TorrentListEvent {
  const FetchTorrentListEvent();
}

class RefreshTorrentListEvent extends TorrentListEvent {
  const RefreshTorrentListEvent();
}

class SearchTorrentEvent extends TorrentListEvent {
  final String query;

  const SearchTorrentEvent({required this.query});

  @override
  List<Object?> get props => <Object?>[query];
}

class SortTorrentEvent extends TorrentListEvent {
  final String sortField;
  final String sortOrder;

  const SortTorrentEvent({required this.sortField, required this.sortOrder});

  @override
  List<Object?> get props => <Object?>[sortField, sortOrder];
}

class FilterTorrentStatusEvent extends TorrentListEvent {
  final String filterStatus;

  const FilterTorrentStatusEvent({required this.filterStatus});

  @override
  List<Object?> get props => <Object?>[filterStatus];
}

class FilterTorrentCategoryEvent extends TorrentListEvent {
  final String filterCategory;

  const FilterTorrentCategoryEvent({required this.filterCategory});

  @override
  List<Object?> get props => <Object?>[filterCategory];
}

class LoadMoreTorrentsEvent extends TorrentListEvent {
  const LoadMoreTorrentsEvent();
}
