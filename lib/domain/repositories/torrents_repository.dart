import 'package:nyaa_si_mobile/domain/entities/nyaa_torrent_entities.dart';

abstract class TorrentsRepository {
  Future<List<NyaaTorrentEntity>> fetchTorrents({
    int page,
    String query,
    String filter,
    String category,
    String sort,
    String order,
  });
}
