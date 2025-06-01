import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyaa_si_mobile/domain/entities/release_group_entity.dart';

import '../../blocs/downloaded_torrent/downloaded_torrent_bloc.dart';
import '../../widgets/downloaded_torrent/release_group_card_widget.dart';

@RoutePage()
class DownloadedTorrentHomePage extends StatelessWidget {
  const DownloadedTorrentHomePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<DownloadedTorrentBloc>(
    create:
        (BuildContext context) =>
            DownloadedTorrentBloc()..add(LoadDownloadedTorrents()),
    child: const HomePageContent(),
  );
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Downloaded Torrents'),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed:
              () => context.read<DownloadedTorrentBloc>().add(
                RefreshDownloadedTorrents(),
              ),
        ),
      ],
    ),
    body: BlocBuilder<DownloadedTorrentBloc, DownloadedTorrentState>(
      builder:
          (
            BuildContext context,
            DownloadedTorrentState state,
          ) => switch (state) {
            DownloadedTorrentInitial() => const Center(
              child: Text('Welcome to Downloaded Torrents'),
            ),
            DownloadedTorrentLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            DownloadedTorrentLoaded(
              :final List<ReleaseGroupEntity> releaseGroups,
            ) =>
              releaseGroups.isEmpty
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.folder_open, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No downloaded torrents yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : RefreshIndicator(
                    onRefresh: () async {
                      context.read<DownloadedTorrentBloc>().add(
                        RefreshDownloadedTorrents(),
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: releaseGroups.length,
                      itemBuilder: (BuildContext context, int index) {
                        final ReleaseGroupEntity group = releaseGroups[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ReleaseGroupCard(
                            group: group,
                            onDeleteTorrent: (String torrentId) {
                              context.read<DownloadedTorrentBloc>().add(
                                DeleteTorrent(torrentId),
                              );
                            },
                            onDeleteReleaseGroup: (String groupName) {
                              context.read<DownloadedTorrentBloc>().add(
                                DeleteReleaseGroup(groupName),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
            DownloadedTorrentError() => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.errorMessage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => context.read<DownloadedTorrentBloc>().add(
                          LoadDownloadedTorrents(),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          },
    ),
  );
}
