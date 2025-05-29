import '../entities/nyaa_torrent_entity.dart';

abstract class TorrentsRepository {
  Future<List<NyaaTorrentEntity>> fetchTorrents({
    required int page,
    required int pageSize,
    required String searchQuery,
    required String filterStatus,
    required String filterCategory,
    required String sortField,
    required String sortOrder,
  });

  Future<String> downloadTorrent({required String torrentId, String? releaseGroup});
}
