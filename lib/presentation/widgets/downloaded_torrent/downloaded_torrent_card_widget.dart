import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/services/navigation_service/app_router_service.gr.dart';
import '../../../domain/entities/downloaded_torrent_entity.dart';

class DownloadedTorrentCardWidget extends StatelessWidget {
  final DownloadedTorrentEntity torrent;
  final void Function(String) onDeleteTorrent;

  const DownloadedTorrentCardWidget({
    super.key,
    required this.torrent,
    required this.onDeleteTorrent,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: () => _openFile(context),
      onLongPress: () => _showOptions(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              torrent.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Icon(Icons.storage, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatSize(torrent.size),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const Spacer(),
                Text(
                  _formatDate(torrent.downloadedAt),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  void _openFile(BuildContext context) {}

  void _showOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder:
          (BuildContext context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share'),
                  onTap: () {
                    context.router.maybePop();
                    _shareFile(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('File Info'),
                  onTap: () {
                    context.router.maybePop();
                    _showFileInfo(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete'),
                  onTap: () {
                    context.router.maybePop();
                    _confirmDelete(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _shareFile(BuildContext context) {}

  void _showFileInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('File Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildInfoRow('Name', torrent.name),
                _buildInfoRow('Size', _formatSize(torrent.size)),
                _buildInfoRow('Downloaded', _formatDate(torrent.downloadedAt)),
                _buildInfoRow('Path', torrent.path),
                if (torrent.releaseGroup != null)
                  _buildInfoRow('Release Group', torrent.releaseGroup!),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => context.router.maybePop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(color: Colors.grey)),
      ],
    ),
  );

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Delete Torrent'),
            content: Text('Are you sure you want to delete "${torrent.name}"?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => context.router.maybePop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.router.replaceAll(<PageRouteInfo<Object?>>[
                    const HomeRoute(),
                    const DownloadedTorrentHomeRoute(),
                  ]);
                  onDeleteTorrent(torrent.id);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
