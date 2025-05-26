import 'package:nyaa_si_mobile/domain/entities/nyaa_torrent_entities.dart';
import 'package:nyaa_si_mobile/domain/repositories/torrents_repository.dart';

class FetchTorrentsUseCase {
  final TorrentsRepository _repository;

  FetchTorrentsUseCase(this._repository);

  Future<List<NyaaTorrentEntity>> call({
    required int page,
    required int pageSize,
    required String filterStatus,
    required String filterCategory,
    required String searchQuery,
    required String sortField,
    required String sortOrder,
  }) async => await _repository.fetchTorrents(
      page: page,
      pageSize: pageSize,
      filterStatus: filterStatus,
      filterCategory: filterCategory,
      searchQuery: searchQuery,
      sortField: sortField,
      sortOrder: sortOrder,
    );
}
