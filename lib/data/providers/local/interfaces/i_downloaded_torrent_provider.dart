import '../../../models/downloaded_torrent_model.dart';

abstract class IDownloadedTorrentProvider {
  Future<List<DownloadedTorrentModel>> getAllDownloadedTorrents();
  
  Future<void> deleteTorrent(String torrentId);
  
  Future<void> deleteReleaseGroup(String releaseGroupName);
  
  Future<String> saveDownloadedTorrent({
    required String fileName,
    required List<int> bytes,
    String? releaseGroup,
  });
}
