part of 'torrent_download_bloc.dart';

sealed class TorrentDownloadEvent extends Equatable {
  const TorrentDownloadEvent();

  @override
  List<Object> get props => <Object>[];
}

class DownloadTorrentEvent extends TorrentDownloadEvent {
  final NyaaTorrentEntity torrent;

  const DownloadTorrentEvent({required this.torrent});

  @override
  List<Object> get props => <Object>[torrent];
}
