import 'package:flutter/material.dart';
import 'package:nyaa_si_mobile/domain/entities/nyaa_torrent_entities.dart';

class TorrentCard extends StatelessWidget {
  final NyaaTorrentEntity torrent;

  const TorrentCard({super.key, required this.torrent});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    elevation: 2.0,
    color: _getCardColor(torrent.torrentStatus),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            torrent.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _buildInfoChip(Icons.category, torrent.category),
              _buildInfoChip(Icons.straighten, torrent.size),
              _buildInfoChip(Icons.calendar_today, torrent.date),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: <Widget>[
                    _buildStatusChip(
                      Icons.arrow_upward,
                      torrent.seeders.toString(),
                      Colors.green,
                    ),
                    _buildStatusChip(
                      Icons.arrow_downward,
                      torrent.leechers.toString(),
                      Colors.red,
                    ),
                    _buildStatusChip(
                      Icons.check_circle_outline,
                      torrent.completed.toString(),
                      Colors.blue,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.file_download),
                tooltip: 'Download Torrent',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.link),
                tooltip: 'Magnet Link',
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildInfoChip(IconData icon, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Icon(icon, size: 16),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 14)),
    ],
  );

  Widget _buildStatusChip(IconData icon, String label, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      );

  Color _getCardColor(String status) {
    switch (status) {
      case 'success':
        return Colors.green.withValues(alpha: 0.05);
      case 'danger':
        return Colors.red.withValues(alpha: 0.05);
      default:
        return Colors.white;
    }
  }
}
