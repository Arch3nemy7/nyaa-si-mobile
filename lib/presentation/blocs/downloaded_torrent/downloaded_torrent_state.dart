part of 'downloaded_torrent_bloc.dart';

sealed class DownloadedTorrentState extends Equatable {
  const DownloadedTorrentState();

  @override
  List<Object> get props => <Object>[];
}

class DownloadedTorrentInitial extends DownloadedTorrentState {}

class DownloadedTorrentLoading extends DownloadedTorrentState {}

class DownloadedTorrentLoaded extends DownloadedTorrentState {
  final List<ReleaseGroupEntity> releaseGroups;
  final List<DownloadedTorrentEntity> allTorrents;

  const DownloadedTorrentLoaded({
    required this.releaseGroups,
    required this.allTorrents,
  });

  @override
  List<Object> get props => <Object>[releaseGroups, allTorrents];
}

class DownloadedTorrentError extends DownloadedTorrentState {
  final String errorMessage;

  const DownloadedTorrentError({required this.errorMessage});

  @override
  List<Object> get props => <Object>[errorMessage];
}
