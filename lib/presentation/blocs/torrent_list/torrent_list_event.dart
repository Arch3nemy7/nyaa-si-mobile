part of 'torrent_list_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => <Object>[];
}

class FetchTorrentListEvent extends HomeEvent {
  const FetchTorrentListEvent();
}

class RefreshTorrentListEvent extends HomeEvent {
  const RefreshTorrentListEvent();
}
