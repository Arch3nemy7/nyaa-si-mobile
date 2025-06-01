import 'dart:io';
import 'package:path/path.dart' as path;

import '../../models/downloaded_torrent_model.dart';

class DownloadedTorrentProvider {
  static const String _nyaaFolderName = 'Nyaa';

  Future<String> get _downloadsPath async {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Download';
    } else {
      throw Exception(
        'Unsupported platform for torrent downloads: ${Platform.operatingSystem}',
      );
    }
  }

  Future<String> get _nyaaPath async {
    final String downloadsPath = await _downloadsPath;
    return path.join(downloadsPath, _nyaaFolderName);
  }

  Future<List<DownloadedTorrentModel>> getAllDownloadedTorrents() async {
    try {
      final String nyaaPath = await _nyaaPath;
      final Directory nyaaDirectory = Directory(nyaaPath);

      if (!await nyaaDirectory.exists()) {
        return <DownloadedTorrentModel>[];
      }

      final List<DownloadedTorrentModel> torrents = <DownloadedTorrentModel>[];

      await for (final FileSystemEntity entity in nyaaDirectory.list(
        recursive: true,
      )) {
        if (entity is File && entity.path.endsWith('.torrent')) {
          final DownloadedTorrentModel? torrent = await _createTorrentFromFile(
            entity,
          );
          if (torrent != null) {
            torrents.add(torrent);
          }
        }
      }

      torrents.sort(
        (DownloadedTorrentModel a, DownloadedTorrentModel b) =>
            b.downloadedAt.compareTo(a.downloadedAt),
      );

      return torrents;
    } catch (e) {
      throw Exception('Failed to scan torrent files: $e');
    }
  }

  Future<DownloadedTorrentModel?> _createTorrentFromFile(File file) async {
    try {
      final FileStat stat = await file.stat();
      final String fileName = path.basenameWithoutExtension(file.path);
      final String? releaseGroup = _extractReleaseGroup(file.path);

      return DownloadedTorrentModel(
        id: _generateIdFromPath(file.path),
        name: fileName,
        path: file.path,
        size: stat.size,
        downloadedAt: stat.modified,
        releaseGroup: releaseGroup,
      );
    } catch (e) {
      return null;
    }
  }

  String _generateIdFromPath(String filePath) =>
      filePath.hashCode.abs().toString();

  String? _extractReleaseGroup(String filePath) {
    final String nyaaPath = path.dirname(filePath);
    final List<String> pathParts = nyaaPath.split(Platform.pathSeparator);

    final int nyaaIndex = pathParts.indexWhere(
      (String part) => part == _nyaaFolderName,
    );

    if (nyaaIndex != -1 && nyaaIndex < pathParts.length - 1) {
      return pathParts[nyaaIndex + 1];
    }

    return null;
  }

  Future<void> deleteTorrent(String torrentId) async {
    try {
      final List<DownloadedTorrentModel> torrents =
          await getAllDownloadedTorrents();
      final DownloadedTorrentModel? torrent = torrents.firstWhereOrNull(
        (DownloadedTorrentModel t) => t.id == torrentId,
      );

      if (torrent != null) {
        final File file = File(torrent.path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      throw Exception('Failed to delete torrent file: $e');
    }
  }

  Future<void> deleteReleaseGroup(String releaseGroupName) async {
    try {
      final String nyaaPath = await _nyaaPath;
      final String groupPath = path.join(nyaaPath, releaseGroupName);
      final Directory groupDirectory = Directory(groupPath);

      if (await groupDirectory.exists()) {
        await groupDirectory.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('Failed to delete release group folder: $e');
    }
  }

  Future<String> saveDownloadedTorrent({
    required String fileName,
    required List<int> bytes,
    String? releaseGroup,
  }) async {
    try {
      final String nyaaPath = await _nyaaPath;

      String targetPath = nyaaPath;
      if (releaseGroup != null && releaseGroup.isNotEmpty) {
        targetPath = path.join(nyaaPath, _sanitizeDirectoryName(releaseGroup));
      }

      final Directory targetDirectory = Directory(targetPath);
      if (!await targetDirectory.exists()) {
        await targetDirectory.create(recursive: true);
      }

      final String filePath = path.join(targetPath, fileName);
      final File file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      throw Exception('Failed to save torrent file: $e');
    }
  }

  String _sanitizeDirectoryName(String name) =>
      name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
}

extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (T element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
