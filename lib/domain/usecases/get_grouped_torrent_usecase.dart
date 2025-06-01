import '../entities/release_group_entity.dart';
import '../repositories/downloaded_torrent_repository.dart';

class GetGroupedTorrentsUsecase {
  final DownloadedTorrentRepository repository;

  GetGroupedTorrentsUsecase(this.repository);

  Future<List<ReleaseGroupEntity>> call() async =>
      await repository.getGroupedTorrents();
}
