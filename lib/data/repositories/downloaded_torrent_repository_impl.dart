import '../../domain/entities/downloaded_torrent_entity.dart';
import '../../domain/entities/release_group_entity.dart';
import '../../domain/repositories/downloaded_torrent_repository.dart';
import '../models/downloaded_torrent_model.dart';
import '../providers/local/interfaces/i_downloaded_torrent_provider.dart';

class DownloadedTorrentRepositoryImpl implements DownloadedTorrentRepository {
  final IDownloadedTorrentProvider localDataSource;

  DownloadedTorrentRepositoryImpl({required this.localDataSource});

  @override
  Future<List<DownloadedTorrentEntity>> getAllDownloadedTorrents() async {
    try {
      final List<DownloadedTorrentModel> models =
          await localDataSource.getAllDownloadedTorrents();
      return models
          .map((DownloadedTorrentModel model) => model.toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get downloaded torrents: $e');
    }
  }

  @override
  Future<List<ReleaseGroupEntity>> getGroupedTorrents() async {
    try {
      final List<DownloadedTorrentEntity> torrents =
          await getAllDownloadedTorrents();
      final Map<String, List<DownloadedTorrentEntity>> grouped =
          <String, List<DownloadedTorrentEntity>>{};

      for (final DownloadedTorrentEntity torrent in torrents) {
        final String groupName = torrent.releaseGroup ?? 'Unknown';
        grouped
            .putIfAbsent(groupName, () => <DownloadedTorrentEntity>[])
            .add(torrent);
      }

      return grouped.entries
          .map(
            (MapEntry<String, List<DownloadedTorrentEntity>> entry) =>
                ReleaseGroupEntity(name: entry.key, torrents: entry.value),
          )
          .toList()
        ..sort(
          (ReleaseGroupEntity a, ReleaseGroupEntity b) =>
              b.torrentCount.compareTo(a.torrentCount),
        );
    } catch (e) {
      throw Exception('Failed to get grouped torrents: $e');
    }
  }

  @override
  Future<void> deleteTorrent(String torrentId) async {
    try {
      await localDataSource.deleteTorrent(torrentId);
    } catch (e) {
      throw Exception('Failed to delete torrent: $e');
    }
  }

  @override
  Future<void> deleteReleaseGroup(String releaseGroupName) async {
    try {
      await localDataSource.deleteReleaseGroup(releaseGroupName);
    } catch (e) {
      throw Exception('Failed to delete release group: $e');
    }
  }
}
