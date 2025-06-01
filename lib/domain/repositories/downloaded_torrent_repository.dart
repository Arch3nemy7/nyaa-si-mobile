import '../entities/downloaded_torrent_entity.dart';
import '../entities/release_group_entity.dart';

abstract class DownloadedTorrentRepository {
  Future<List<DownloadedTorrentEntity>> getAllDownloadedTorrents();

  Future<List<ReleaseGroupEntity>> getGroupedTorrents();

  Future<void> deleteTorrent(String torrentId);
  
  Future<void> deleteReleaseGroup(String releaseGroupName);
}
