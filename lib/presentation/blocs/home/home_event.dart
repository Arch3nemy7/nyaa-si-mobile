part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => <Object>[];
}

class FetchTorrentsEvent extends HomeEvent {
  const FetchTorrentsEvent();
}

class RefreshTorrentsEvent extends HomeEvent {
  const RefreshTorrentsEvent();
}

class DownloadTorrentEvent extends HomeEvent {
  final NyaaTorrentEntity torrent;

  const DownloadTorrentEvent({required this.torrent});

  @override
  List<Object> get props => <Object>[torrent];
}
