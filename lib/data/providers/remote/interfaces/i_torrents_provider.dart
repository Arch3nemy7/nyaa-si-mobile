import '../../../models/nyaa_torrent_model.dart';

abstract class IRemoteTorrentsProvider {
  Future<List<NyaaTorrentModel>> getTorrents({
    required int page,
    required int pageSize,
    required String filterStatus,
    required String filterCategory,
    required String searchQuery,
    required String sortField,
    required String sortOrder,
  });

  Future<String> downloadTorrent({
    required String torrentId,
    String? releaseGroup,
  });
}
