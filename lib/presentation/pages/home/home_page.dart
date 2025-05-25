import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyaa_si_mobile/domain/entities/nyaa_torrent_entities.dart';
import 'package:nyaa_si_mobile/presentation/blocs/home/home_bloc.dart';
import 'package:nyaa_si_mobile/presentation/widgets/torrent_card_widget.dart';

import '../../../core/constants/constants.dart';

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
    backgroundColor: const Color(0xFFF8FAFB),
    appBar: _buildAppBar(context),
    body: BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        if (state is TorrentsLoadingState) {
          return _buildLoadingState();
        } else if (state is TorrentsLoadedState) {
          return _buildTorrentList(state.torrents);
        } else if (state is TorrentsErrorState) {
          return _buildErrorState(state.error);
        }
        return _buildEmptyState();
      },
    ),
  );

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
    title: Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[nyaaPrimary, nyaaSecondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.pets, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        const Text(
          'Nyaa.si',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ],
    ),
    backgroundColor: Colors.white,
    foregroundColor: nyaaAccent,
    elevation: 0,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              nyaaPrimary.withValues(alpha: 0.1),
              nyaaSecondary.withValues(alpha: 0.1),
            ],
          ),
        ),
      ),
    ),
    actions: <Widget>[
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.search_rounded, color: nyaaPrimary),
      ),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.filter_list_rounded, color: nyaaPrimary),
      ),
    ],
  );

  Widget _buildLoadingState() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Colors.white, nyaaPrimary.withValues(alpha: 0.02)],
      ),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: nyaaPrimary.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(nyaaPrimary),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading torrents...',
            style: TextStyle(color: nyaaAccent, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );

  Widget _buildErrorState(String error) => Center(
    child: Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.error_outline_rounded, size: 48, color: Colors.red[600]),
          const SizedBox(height: 12),
          Text(
            'Oops! Something went wrong',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<HomeBloc>().add(RefreshTorrentsEvent());
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: nyaaPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmptyState() => Center(
    child: Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: nyaaPrimary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.inbox_rounded,
            size: 48,
            color: nyaaPrimary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'No torrents found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: nyaaAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh or check your connection',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _buildTorrentList(List<NyaaTorrentEntity> torrents) =>
      RefreshIndicator(
        onRefresh: () async {
          context.read<HomeBloc>().add(RefreshTorrentsEvent());
        },
        color: nyaaPrimary,
        backgroundColor: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.white,
                nyaaPrimary.withValues(alpha: 0.01),
              ],
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: torrents.length,
            itemBuilder: (BuildContext context, int index) {
              final NyaaTorrentEntity torrent = torrents[index];
              return TorrentCardWidget(torrent: torrent);
            },
          ),
        ),
      );
}
