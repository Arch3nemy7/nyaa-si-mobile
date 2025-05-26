import '../../domain/entities/nyaa_torrent_entities.dart';

class NyaaTorrentModel extends NyaaTorrentEntity {
  NyaaTorrentModel({
    required super.id,
    required super.category,
    required super.categoryImage,
    required super.name,
    super.releaseGroup,
    required super.link,
    required super.comments,
    required super.torrentLink,
    required super.magnetLink,
    required super.size,
    required super.date,
    super.timestamp,
    required super.seeders,
    required super.leechers,
    required super.completed,
    required super.torrentStatus,
  });

  factory NyaaTorrentModel.fromJson(Map<String, dynamic> json) =>
      NyaaTorrentModel(
        id: json['id'] as String? ?? '',
        category: json['category'] as String? ?? '',
        categoryImage: json['categoryImage'] as String? ?? '',
        name: json['name'] as String? ?? '',
        releaseGroup: json['releaseGroup'] as String?,
        link: json['link'] as String? ?? '',
        comments: json['comments'] as int? ?? 0,
        torrentLink: json['torrentLink'] as String? ?? '',
        magnetLink: json['magnetLink'] as String? ?? '',
        size: json['size'] as String? ?? '',
        date: json['date'] as String? ?? '',
        timestamp: json['timestamp'] as int?,
        seeders: json['seeders'] as int? ?? 0,
        leechers: json['leechers'] as int? ?? 0,
        completed: json['completed'] as int? ?? 0,
        torrentStatus: json['torrentStatus'] as String? ?? 'default',
      );
}
