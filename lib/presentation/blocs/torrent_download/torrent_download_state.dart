part of 'torrent_download_bloc.dart';

sealed class TorrentDownloadState extends Equatable {
  const TorrentDownloadState();

  @override
  List<Object> get props => <Object>[];
}

final class TorrentDownloadInitial extends TorrentDownloadState {
  const TorrentDownloadInitial();
}

final class TorrentDownloading extends TorrentDownloadState {
  final String torrentId;

  const TorrentDownloading({required this.torrentId});

  @override
  List<Object> get props => <Object>[torrentId];
}

final class TorrentDownloadSuccess extends TorrentDownloadState {
  final String torrentId;
  final String filePath;

  const TorrentDownloadSuccess({
    required this.torrentId,
    required this.filePath,
  });

  @override
  List<Object> get props => <Object>[torrentId, filePath];
}

final class TorrentDownloadFailure extends TorrentDownloadState {
  final String torrentId;
  final String error;

  const TorrentDownloadFailure({required this.torrentId, required this.error});

  @override
  List<Object> get props => <Object>[torrentId, error];
}
