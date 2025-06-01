import '../repositories/downloaded_torrent_repository.dart';

class DeleteTorrentUsecase {
  final DownloadedTorrentRepository repository;

  DeleteTorrentUsecase(this.repository);

  Future<void> call(String torrentId) async =>
      await repository.deleteTorrent(torrentId);
}
