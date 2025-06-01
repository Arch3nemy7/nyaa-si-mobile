part of 'downloaded_torrent_bloc.dart';

sealed class DownloadedTorrentEvent extends Equatable {
  const DownloadedTorrentEvent();

  @override
  List<Object> get props => <Object>[];
}

class LoadDownloadedTorrents extends DownloadedTorrentEvent {}

class RefreshDownloadedTorrents extends DownloadedTorrentEvent {}

class DeleteTorrent extends DownloadedTorrentEvent {
  final String torrentId;
  
  const DeleteTorrent(this.torrentId);

  @override
  List<Object> get props => <Object>[torrentId];
}

class DeleteReleaseGroup extends DownloadedTorrentEvent {
  final String releaseGroupName;

  const DeleteReleaseGroup(this.releaseGroupName);

  @override
  List<Object> get props => <Object>[releaseGroupName];
}
