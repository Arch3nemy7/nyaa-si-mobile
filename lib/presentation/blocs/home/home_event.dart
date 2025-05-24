part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => <Object>[];
}

class FetchTorrentsEvent extends HomeEvent {
  final int page;
  final String query;
  final String filter;
  final String category;
  final String sort;
  final String order;

  const FetchTorrentsEvent({
    this.page = 1,
    this.query = '',
    this.filter = '0',
    this.category = '0_0',
    this.sort = 'id',
    this.order = 'desc',
  });

  @override
  List<Object> get props =>
      <Object>[page, query, filter, category, sort, order];
}

class TorrentsFetchedEvent extends HomeEvent {
  final List<NyaaTorrentEntity> torrents;

  const TorrentsFetchedEvent({required this.torrents});

  @override
  List<Object> get props => <Object>[torrents];
}

class RefreshTorrentsEvent extends HomeEvent {}
