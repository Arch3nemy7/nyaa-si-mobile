import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyaa_si_mobile/domain/entities/nyaa_torrent_entities.dart';
import 'package:nyaa_si_mobile/presentation/blocs/home/home_bloc.dart';
import 'package:nyaa_si_mobile/presentation/widgets/torrent_card.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<HomeBloc>(
    create:
        (BuildContext context) => HomeBloc()..add(const FetchTorrentsEvent()),
    child: const _HomePageContent(),
  );
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nyaa.si Torrents')),
    body: BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        if (state is TorrentsLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TorrentsLoadedState) {
          return _buildTorrentList(state.torrents);
        } else if (state is TorrentsErrorState) {
          return Center(
            child: Text(
              'Error: ${state.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        return const Center(child: Text('No torrents found'));
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        context.read<HomeBloc>().add(RefreshTorrentsEvent());
      },
      child: const Icon(Icons.refresh),
    ),
  );

  Widget _buildTorrentList(List<NyaaTorrentEntity> torrents) =>
      RefreshIndicator(
        onRefresh: () async {
          context.read<HomeBloc>().add(RefreshTorrentsEvent());
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: torrents.length,
          itemBuilder: (BuildContext context, int index) {
            final NyaaTorrentEntity torrent = torrents[index];
            return TorrentCard(torrent: torrent);
          },
        ),
      );
}
