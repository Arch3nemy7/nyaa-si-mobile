import 'downloaded_torrent_entity.dart';

class ReleaseGroupEntity {
  final String name;
  final List<DownloadedTorrentEntity> torrents;
  final String totalSize;

  ReleaseGroupEntity({required this.name, required this.torrents})
    : totalSize = _calculateTotalSize(torrents);

  int get torrentCount => torrents.length;

  static String _calculateTotalSize(List<DownloadedTorrentEntity> torrents) {
    if (torrents.isEmpty) return '0 B';

    double totalBytes = 0;
    for (final DownloadedTorrentEntity torrent in torrents) {
      totalBytes += _parseSize(torrent.size.toString());
    }

    return _formatBytes(totalBytes);
  }

  static double _parseSize(String sizeText) {
    try {
      final RegExp sizeRegex = RegExp(
        r'([\d.]+)\s*([KMGT]?i?B)',
        caseSensitive: false,
      );
      final RegExpMatch? match = sizeRegex.firstMatch(sizeText.trim());

      if (match != null) {
        final double value = double.parse(match.group(1)!);
        final String unit = match.group(2)!.toLowerCase();

        switch (unit) {
          case 'tib':
          case 'tb':
            return value * 1024 * 1024 * 1024 * 1024;
          case 'gib':
          case 'gb':
            return value * 1024 * 1024 * 1024;
          case 'mib':
          case 'mb':
            return value * 1024 * 1024;
          case 'kib':
          case 'kb':
            return value * 1024;
          case 'b':
          default:
            return value;
        }
      }

      return double.tryParse(sizeText.trim()) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  static String _formatBytes(double bytes) {
    if (bytes >= 1024 * 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(1)} TiB';
    } else if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GiB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MiB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KiB';
    } else {
      return '${bytes.toStringAsFixed(0)} B';
    }
  }
}
