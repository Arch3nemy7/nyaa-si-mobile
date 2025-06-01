class DownloadedTorrentEntity {
  final String id;
  final String name;
  final String path;
  final int size;
  final DateTime downloadedAt;
  final String? releaseGroup;

  DownloadedTorrentEntity({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.downloadedAt,
    this.releaseGroup,
  });
}
