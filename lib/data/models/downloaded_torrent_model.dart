import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/downloaded_torrent_entity.dart';

part 'downloaded_torrent_model.g.dart';

@HiveType(typeId: 0)
class DownloadedTorrentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String path;

  @HiveField(3)
  final int size;

  @HiveField(4)
  final DateTime downloadedAt;

  @HiveField(5)
  final String? releaseGroup;

  DownloadedTorrentModel({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.downloadedAt,
    this.releaseGroup,
  });

  factory DownloadedTorrentModel.fromEntity(
    DownloadedTorrentEntity entity,
  ) => DownloadedTorrentModel(
    id: entity.id,
    name: entity.name,
    path: entity.path,
    size: entity.size,
    downloadedAt: entity.downloadedAt,
    releaseGroup: entity.releaseGroup,
  );

  DownloadedTorrentEntity toEntity() => DownloadedTorrentEntity(
    id: id,
    name: name,
    path: path,
    size: size,
    downloadedAt: downloadedAt,
    releaseGroup: releaseGroup,
  );
}
