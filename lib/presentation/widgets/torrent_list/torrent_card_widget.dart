import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/constants.dart';
import '../../../domain/entities/nyaa_torrent_entity.dart';
import '../../blocs/torrent_download/torrent_download_bloc.dart';

class TorrentCardWidget extends StatelessWidget {
  final NyaaTorrentEntity torrent;

  const TorrentCardWidget({super.key, required this.torrent});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color:
          torrent.torrentStatus == 'danger'
              ? const Color.fromRGBO(208, 0, 0, 0.12)
              : torrent.torrentStatus == 'success'
              ? const Color.fromRGBO(60, 206, 0, 0.12)
              : nyaaPrimaryContainerBackground,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: nyaaPrimaryBorder),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeaderRow(context),
            if (torrent.releaseGroup != null) ...<Widget>[
              const SizedBox(height: 8),
              _buildReleaseGroupBadge(),
            ],
            const SizedBox(height: 8),
            _buildTitleRow(context),
            const SizedBox(height: 8),
            _buildSizeInfo(context),
            const SizedBox(height: 8),
            _buildStatsRow(context),
            const SizedBox(height: 8),
            _buildActionButtons(context),
          ],
        ),
      ),
    ),
  );

  Widget _buildHeaderRow(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[_buildCategoryBadge(), _buildDateText(context)],
  );

  Widget _buildTitleRow(BuildContext context) => Text(
    torrent.name,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.w700,
      height: 1.3,
      letterSpacing: -0.2,
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
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

  Widget _buildActionButtons(
    BuildContext context,
  ) => BlocConsumer<TorrentDownloadBloc, TorrentDownloadState>(
    listener: (BuildContext context, TorrentDownloadState state) {
      if (state is TorrentDownloadSuccess && state.torrentId == torrent.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Torrent downloaded successfully. \nFile saved at: Download/Nyaa',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (state is TorrentDownloadFailure &&
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
    builder: (BuildContext context, TorrentDownloadState state) {
      final bool isDownloading =
          state is TorrentDownloading && state.torrentId == torrent.id;

      return Row(
        children: <Widget>[
          Expanded(child: _buildDownloadButton(context, isDownloading)),
          const SizedBox(width: 8),
          Expanded(child: _buildMagnetButton()),
        ],
      );
    },
  );

  Widget _buildDateText(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: nyaaPrimaryBorder),
    ),
    child: Text(
      torrent.date,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontSize: 10,
        color: nyaaAccent.withValues(alpha: 0.9),
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _buildCategoryBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: nyaaPrimaryBorder),
    ),
    child: Text(
      torrent.category,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 10,
        color: nyaaAccent.withValues(alpha: 0.9),
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _buildReleaseGroupBadge() => Container(
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
  );

  Widget _buildSizeInfo(BuildContext context) => Row(
    children: <Widget>[
      const Icon(Icons.storage_outlined, size: 12, color: nyaaAccent),
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
      color: Color.lerp(Colors.white, color, 0.025),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
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

  Widget _buildDownloadButton(BuildContext context, bool isLoading) => SizedBox(
    height: 32,
    child: ElevatedButton(
      onPressed:
          isLoading
              ? null
              : () => context.read<TorrentDownloadBloc>().add(
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
        backgroundColor: Colors.white,
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
}
