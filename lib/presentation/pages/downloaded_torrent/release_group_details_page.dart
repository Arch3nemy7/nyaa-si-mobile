import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:nyaa_si_mobile/domain/entities/downloaded_torrent_entity.dart';

import '../../../core/services/navigation_service/app_router_service.gr.dart';
import '../../../domain/entities/release_group_entity.dart';
import '../../widgets/downloaded_torrent/downloaded_torrent_card_widget.dart';

@RoutePage()
class ReleaseGroupDetailsPage extends StatelessWidget {
  final ReleaseGroupEntity group;
  final void Function(String) onDeleteTorrent;
  final void Function(String) onDeleteReleaseGroup;

  const ReleaseGroupDetailsPage({
    super.key,
    required this.group,
    required this.onDeleteTorrent,
    required this.onDeleteReleaseGroup,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(group.name),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _confirmDeleteGroup(context),
        ),
      ],
    ),
    body: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: group.torrents.length,
      itemBuilder: (BuildContext context, int index) {
        final DownloadedTorrentEntity torrent = group.torrents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: DownloadedTorrentCardWidget(
            torrent: torrent,
            onDeleteTorrent: onDeleteTorrent,
          ),
        );
      },
    ),
  );

  void _confirmDeleteGroup(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Delete Release Group'),
            content: Text(
              'Are you sure you want to delete all ${group.torrentCount} files from "${group.name}"?',
            ),
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
                  onDeleteReleaseGroup(group.name);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
