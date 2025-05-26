import '../repositories/torrents_repository.dart';

class DownloadTorrentUsecase {
  final TorrentsRepository _torrentsRepository;

  DownloadTorrentUsecase(this._torrentsRepository);

  Future<String> call({required String torrentId}) async =>
      await _torrentsRepository.downloadTorrent(torrentId: torrentId);
}
