import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../domain/entities/nyaa_torrent_entities.dart';

class TorrentCardWidget extends StatelessWidget {
  final NyaaTorrentEntity torrent;

  const TorrentCardWidget({super.key, required this.torrent});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: nyaaPrimary.withValues(alpha: 0.08)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: nyaaPrimary.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeaderRow(context),
              const SizedBox(height: 8),
              _buildTitleRow(context),
              const SizedBox(height: 8),
              _buildStatsRow(context),
              const SizedBox(height: 8),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildHeaderRow(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Row(
        children: <Widget>[
          _buildStatusBadge(torrent.torrentStatus),
          if (torrent.releaseGroup != null) ...<Widget>[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[nyaaPrimary, nyaaSecondary],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                torrent.releaseGroup!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
      Text(
        torrent.date,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 10,
        ),
      ),
    ],
  );

  Widget _buildTitleRow(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        torrent.name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 4),
      Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: nyaaAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              torrent.category,
              style: const TextStyle(
                fontSize: 9,
                color: nyaaAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.storage_rounded, size: 12, color: nyaaAccent),
          const SizedBox(width: 2),
          Text(
            torrent.size,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: nyaaAccent,
              fontSize: 11,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildStatsRow(BuildContext context) => Row(
    children: <Widget>[
      _buildStatChip(
        icon: Icons.upload_rounded,
        value: torrent.seeders.toString(),
        color: Colors.green[600]!,
        context: context,
      ),
      const SizedBox(width: 8),
      _buildStatChip(
        icon: Icons.download_rounded,
        value: torrent.leechers.toString(),
        color: Colors.orange[600]!,
        context: context,
      ),
      const SizedBox(width: 8),
      _buildStatChip(
        icon: Icons.check_circle_rounded,
        value: torrent.completed.toString(),
        color: nyaaPrimary,
        context: context,
      ),
    ],
  );

  Widget _buildActionButtons(BuildContext context) => Row(
    children: <Widget>[
      Expanded(
        child: SizedBox(
          height: 32,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: nyaaPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 1,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.download_rounded, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text('Download Torrent', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: SizedBox(
          height: 32,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: nyaaPrimary),
              foregroundColor: nyaaPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.link_rounded, size: 16, color: nyaaPrimary),
                SizedBox(width: 4),
                Text('Magnet', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required Color color,
    required BuildContext context,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'success':
        color = Colors.green[600]!;
        label = 'TRUSTED';
        break;
      case 'danger':
        color = Colors.red[600]!;
        label = 'REMAKE';
        break;
      default:
        color = Colors.grey[600]!;
        label = 'NORMAL';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
