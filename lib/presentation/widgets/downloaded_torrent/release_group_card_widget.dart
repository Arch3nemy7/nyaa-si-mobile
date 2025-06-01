import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:nyaa_si_mobile/core/services/navigation_service/app_router_service.gr.dart';

import '../../../domain/entities/release_group_entity.dart';

class ReleaseGroupCard extends StatelessWidget {
  final ReleaseGroupEntity group;
  final void Function(String) onDeleteTorrent;
  final void Function(String) onDeleteReleaseGroup;

  const ReleaseGroupCard({
    super.key,
    required this.group,
    required this.onDeleteTorrent,
    required this.onDeleteReleaseGroup,
  });

  @override
  Widget build(BuildContext context) => Card(
    elevation: 2,
    child: InkWell(
      onTap:
          () => context.router.push(
            ReleaseGroupDetailsRoute(
              group: group,
              onDeleteTorrent: onDeleteTorrent,
              onDeleteReleaseGroup: onDeleteReleaseGroup,
            ),
          ),
      onLongPress: () => _showGroupOptions(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.folder,
                size: 24,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    group.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${group.torrentCount} files • ${group.totalSize}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    ),
  );

  void _showGroupOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder:
          (BuildContext context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete All'),
                  subtitle: Text('Delete all ${group.torrentCount} files'),
                  onTap: () {
                    context.router.maybePop();
                    _confirmDeleteGroup(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.folder_open),
                  title: const Text('Open Folder'),
                  onTap: () {
                    context.router.maybePop();
                    _openFolder(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

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
                  context.router.maybePop();
                  onDeleteReleaseGroup(group.name);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _openFolder(BuildContext context) {}
}
