import '../entities/downloaded_torrent_entity.dart';
import '../repositories/downloaded_torrent_repository.dart';

class GetAllDownloadedTorrentsUsecase {
  final DownloadedTorrentRepository repository;

  GetAllDownloadedTorrentsUsecase(this.repository);

  Future<List<DownloadedTorrentEntity>> call() async =>
      await repository.getAllDownloadedTorrents();
}
