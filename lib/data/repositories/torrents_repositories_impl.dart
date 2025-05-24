import 'package:nyaa_si_mobile/data/providers/remote_torrents_provider.dart';
import 'package:nyaa_si_mobile/domain/entities/nyaa_torrent_entities.dart';
import 'package:nyaa_si_mobile/domain/repositories/torrents_repository.dart';

class TorrentsRepositoryImpl implements TorrentsRepository {
  final RemoteTorrentsProvider _remoteTorrentsProvider;

  TorrentsRepositoryImpl(this._remoteTorrentsProvider);

  @override
  Future<List<NyaaTorrentEntity>> fetchTorrents({
    int page = 1,
    String query = '',
    String filter = '0',
    String category = '0_0',
    String sort = 'id',
    String order = 'desc',
  }) async => await _remoteTorrentsProvider.getTorrents(
      page: page,
      query: query,
      filter: filter,
      category: category,
      sort: sort,
      order: order,
    );
}
