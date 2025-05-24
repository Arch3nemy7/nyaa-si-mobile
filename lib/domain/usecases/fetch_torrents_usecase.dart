import 'package:nyaa_si_mobile/domain/entities/nyaa_torrent_entities.dart';
import 'package:nyaa_si_mobile/domain/repositories/torrents_repository.dart';

class FetchTorrentsUseCase {
  final TorrentsRepository _repository;

  FetchTorrentsUseCase(this._repository);

  Future<List<NyaaTorrentEntity>> call({
    int page = 1,
    String query = '',
    String filter = '0',
    String category = '0_0',
    String sort = 'id',
    String order = 'desc',
  }) async => await _repository.fetchTorrents(
      page: page,
      query: query,
      filter: filter,
      category: category,
      sort: sort,
      order: order,
    );
}
