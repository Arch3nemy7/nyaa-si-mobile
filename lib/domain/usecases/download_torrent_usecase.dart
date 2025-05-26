import '../repositories/torrents_repository.dart';

class DownloadTorrentUseCase {
  final TorrentsRepository _torrentsRepository;

  DownloadTorrentUseCase(this._torrentsRepository);

  Future<String> call({required String torrentId}) async =>
      await _torrentsRepository.downloadTorrent(torrentId: torrentId);
}
