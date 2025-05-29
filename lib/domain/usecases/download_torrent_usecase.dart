import '../repositories/torrents_repository.dart';

class DownloadTorrentUsecase {
  final TorrentsRepository _torrentsRepository;

  DownloadTorrentUsecase(this._torrentsRepository);

  Future<String> call({
    required String torrentId,
    String? releaseGroup,
  }) async => await _torrentsRepository.downloadTorrent(
    torrentId: torrentId,
    releaseGroup: releaseGroup,
  );
}
