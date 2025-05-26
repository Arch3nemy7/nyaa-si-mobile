import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/constants.dart';
import '../../domain/entities/nyaa_torrent_entities.dart';
import '../blocs/home/home_bloc.dart';

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
            _buildReleaseGroupBadge(torrent.releaseGroup!),
          ],
        ],
      ),
      _buildDateText(context),
    ],
  );

  Widget _buildTitleRow(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        torrent.name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey[800],
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 4),
      Row(
        children: <Widget>[
          _buildCategoryBadge(),
          const SizedBox(width: 8),
          _buildSizeInfo(context),
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
      ),
      const SizedBox(width: 8),
      _buildStatChip(
        icon: Icons.download_rounded,
        value: torrent.leechers.toString(),
        color: Colors.orange[600]!,
      ),
      const SizedBox(width: 8),
      _buildStatChip(
        icon: Icons.check_circle_rounded,
        value: torrent.completed.toString(),
        color: nyaaPrimary,
      ),
    ],
  );

  Widget _buildActionButtons(BuildContext context) =>
      BlocConsumer<HomeBloc, HomeState>(
        listener: (BuildContext context, HomeState state) {
          if (state is TorrentDownloadedState &&
              state.torrentId == torrent.id) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Downloaded to: ${state.filePath}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is TorrentDownloadErrorState &&
              state.torrentId == torrent.id) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Download failed: ${state.error}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        builder: (BuildContext context, HomeState state) {
          final bool isDownloading = _isDownloading(state);

          return Row(
            children: <Widget>[
              Expanded(child: _buildDownloadButton(context, isDownloading)),
              const SizedBox(width: 8),
              Expanded(child: _buildMagnetButton()),
            ],
          );
        },
      );

  bool _isDownloading(HomeState state) {
    if (state is TorrentsLoadedState) {
      return state.downloadingTorrents[torrent.id] ?? false;
    } else if (state is TorrentDownloadedState) {
      return state.downloadingTorrents[torrent.id] ?? false;
    } else if (state is TorrentDownloadErrorState) {
      return state.downloadingTorrents[torrent.id] ?? false;
    }
    return false;
  }

  Widget _buildDownloadButton(BuildContext context, bool isLoading) => SizedBox(
    height: 32,
    child: ElevatedButton(
      onPressed:
          isLoading
              ? null
              : () => context.read<HomeBloc>().add(
                DownloadTorrentEvent(torrent: torrent),
              ),
      style: ElevatedButton.styleFrom(
        backgroundColor: nyaaPrimary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: nyaaPrimary.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child:
          isLoading
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.download_rounded, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text('Download Torrent', style: TextStyle(fontSize: 12)),
                ],
              ),
    ),
  );

  Widget _buildMagnetButton() => SizedBox(
    height: 32,
    child: OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: nyaaPrimary),
        foregroundColor: nyaaPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.link_rounded, size: 16, color: nyaaPrimary),
          SizedBox(width: 4),
          Text('Magnet', style: TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );

  Widget _buildReleaseGroupBadge(String releaseGroup) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: <Color>[nyaaPrimary, nyaaSecondary],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      releaseGroup,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
      overflow: TextOverflow.ellipsis,
    ),
  );

  Widget _buildDateText(BuildContext context) => Text(
    torrent.date,
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 10,
    ),
  );

  Widget _buildCategoryBadge() => Container(
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
  );

  Widget _buildSizeInfo(BuildContext context) => Row(
    children: <Widget>[
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
  );

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required Color color,
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
    final (Color color, String label) = switch (status) {
      'success' => (Colors.green[600]!, 'TRUSTED'),
      'danger' => (Colors.red[600]!, 'REMAKE'),
      _ => (Colors.grey[600]!, 'NORMAL'),
    };

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
