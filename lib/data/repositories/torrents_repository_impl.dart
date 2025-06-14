import '../../domain/entities/nyaa_torrent_entity.dart';
import '../../domain/repositories/torrents_repository.dart';
import '../providers/remote/interfaces/i_torrents_provider.dart';

class TorrentsRepositoryImpl implements TorrentsRepository {
  final IRemoteTorrentsProvider _remoteTorrentsProvider;

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
  Future<String> downloadTorrent({
    required String torrentId,
    String? releaseGroup,
  }) async => await _remoteTorrentsProvider.downloadTorrent(
    torrentId: torrentId,
    releaseGroup: releaseGroup,
  );
}
