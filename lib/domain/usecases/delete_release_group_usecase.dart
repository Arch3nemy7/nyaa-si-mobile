import '../repositories/downloaded_torrent_repository.dart';

class DeleteReleaseGroupUsecase {
  final DownloadedTorrentRepository repository;

  DeleteReleaseGroupUsecase(this.repository);

  Future<void> call(String releaseGroupName) async =>
      await repository.deleteReleaseGroup(releaseGroupName);
}
