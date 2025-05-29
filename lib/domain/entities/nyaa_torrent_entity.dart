class NyaaTorrentEntity {
  final String id;
  final String category;
  final String categoryImage;
  final String name;
  final String? releaseGroup;
  final String link;
  final int comments;
  final String torrentLink;
  final String magnetLink;
  final String size;
  final String date;
  final int? timestamp;
  final int seeders;
  final int leechers;
  final int completed;
  final String torrentStatus;

  NyaaTorrentEntity({
    required this.id,
    required this.category,
    required this.categoryImage,
    required this.name,
    this.releaseGroup,
    required this.link,
    required this.comments,
    required this.torrentLink,
    required this.magnetLink,
    required this.size,
    required this.date,
    this.timestamp,
    required this.seeders,
    required this.leechers,
    required this.completed,
    required this.torrentStatus,
  });
}
