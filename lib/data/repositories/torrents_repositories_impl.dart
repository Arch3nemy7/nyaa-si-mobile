import '../../domain/entities/nyaa_torrent_entities.dart';
import '../../domain/repositories/torrents_repository.dart';
import '../providers/remote_torrents_provider.dart';

class TorrentsRepositoryImpl implements TorrentsRepository {
  final RemoteTorrentsProvider _remoteTorrentsProvider;

  TorrentsRepositoryImpl(this._remoteTorrentsProvider);

  @override
  Future<List<NyaaTorrentEntity>> fetchTorrents({
    required int page,
    required int pageSize,
    required String searchQuery,
    required String filterStatus,
    required String filterCategory,
    required String sortField,
    required String sortOrder,
  }) async => await _remoteTorrentsProvider.getTorrents(
    page: page,
    pageSize: pageSize,
    searchQuery: searchQuery,
    filterStatus: filterStatus,
    filterCategory: filterCategory,
    sortField: sortField,
    sortOrder: sortOrder,
  );

  @override
  Future<String> downloadTorrent({required String torrentId}) async =>
      await _remoteTorrentsProvider.downloadTorrent(torrentId: torrentId);
}
