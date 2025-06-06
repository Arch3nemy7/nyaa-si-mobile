import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';

import '../../../core/constants/constants.dart';
import '../../../domain/entities/nyaa_torrent_entity.dart';
import '../../blocs/torrent_download/torrent_download_bloc.dart';
import '../../blocs/torrent_list/torrent_list_bloc.dart';
import '../../widgets/appbar/app_bar_widget.dart';
import '../../widgets/appbar/search_bar_widget.dart';
import '../../widgets/torrent_list/torrent_card_widget.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: <SingleChildWidget>[
      BlocProvider<TorrentListBloc>(
        create:
            (BuildContext context) =>
                TorrentListBloc()..add(const FetchTorrentListEvent()),
      ),
      BlocProvider<TorrentDownloadBloc>(
        create: (BuildContext context) => TorrentDownloadBloc(),
      ),
    ],
    child: const _HomePageContent(),
  );
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TorrentListBloc>().add(const LoadMoreTorrentsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.7);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: buildAppBar(context),
    body: Column(
      children: <Widget>[
        BlocBuilder<TorrentListBloc, TorrentListState>(
          builder: (BuildContext context, TorrentListState state) {
            final TorrentListBloc bloc = context.read<TorrentListBloc>();
            return SearchBarWidget(
              currentSearchQuery: state.searchQuery,
              currentSortField: state.sortField,
              currentSortOrder: state.sortOrder,
              currentFilterStatus: state.filterStatus,
              currentFilterCategory: state.filterCategory,
              onSearch:
                  (String searchQuery) =>
                      bloc.add(SearchTorrentEvent(searchQuery: searchQuery)),
              onSort: (String sortField, String sortOrder) {
                bloc.add(
                  SortTorrentEvent(sortField: sortField, sortOrder: sortOrder),
                );
              },
              onStatusFilter: (String filterStatus) {
                bloc.add(FilterTorrentStatusEvent(filterStatus: filterStatus));
              },
              onFilterCategory: (String filterCategory) {
                bloc.add(
                  FilterTorrentCategoryEvent(filterCategory: filterCategory),
                );
              },
            );
          },
        ),
        Expanded(
          child: BlocBuilder<TorrentListBloc, TorrentListState>(
            builder: (BuildContext context, TorrentListState state) {
              if (state is TorrentListLoadingState) {
                return _buildLoadingState();
              } else if (state is TorrentListLoadedState) {
                return _buildTorrentList(state);
              } else if (state is TorrentListErrorState) {
                return _buildErrorState(state.errorMessage);
              }
              return _buildEmptyState();
            },
          ),
        ),
      ],
    ),
  );

  Widget _buildLoadingState() => Center(
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
              context.read<TorrentListBloc>().add(
                const RefreshTorrentListEvent(),
              );
            },
            icon: const Icon(
              Icons.refresh_rounded,
              size: 16,
              color: Colors.white,
            ),
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
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _buildTorrentList(TorrentListLoadedState state) => RefreshIndicator(
    onRefresh: () async {
      context.read<TorrentListBloc>().add(const RefreshTorrentListEvent());
    },
    color: nyaaPrimary,
    backgroundColor: Colors.white,
    child: ListView.builder(
      controller: _scrollController,
      itemCount: state.torrents.length + (state.hasReachedMax ? 0 : 1),
      itemBuilder: (BuildContext context, int index) {
        if (index >= state.torrents.length) {
          return _buildLoadMoreIndicator(state.isLoadingMore);
        }

        final NyaaTorrentEntity torrent = state.torrents[index];
        return TorrentCardWidget(torrent: torrent);
      },
    ),
  );

  Widget _buildLoadMoreIndicator(bool isLoading) => Container(
    padding: const EdgeInsets.all(16),
    child: Center(
      child:
          isLoading
              ? Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: nyaaPrimary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(nyaaPrimary),
                  ),
                ),
              )
              : const SizedBox.shrink(),
    ),
  );
}
