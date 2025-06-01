import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nyaa_si_mobile/presentation/dependency_injection.dart';

import '../../../domain/entities/downloaded_torrent_entity.dart';
import '../../../domain/entities/release_group_entity.dart';
import '../../../domain/usecases/delete_downloaded_torrent_usecase.dart';
import '../../../domain/usecases/get_all_downloaded_torrents_usecase.dart';
import '../../../domain/usecases/delete_release_group_usecase.dart';
import '../../../domain/usecases/get_grouped_torrent_usecase.dart';

part 'downloaded_torrent_event.dart';
part 'downloaded_torrent_state.dart';

class DownloadedTorrentBloc
    extends Bloc<DownloadedTorrentEvent, DownloadedTorrentState> {
  final GetAllDownloadedTorrentsUsecase getAllDownloadedTorrentsUsecase;
  final GetGroupedTorrentsUsecase getGroupedTorrentsUsecase;
  final DeleteTorrentUsecase deleteTorrentUsecase;
  final DeleteReleaseGroupUsecase deleteReleaseGroupUsecase;

  DownloadedTorrentBloc()
    : getAllDownloadedTorrentsUsecase =
          serviceLocator<GetAllDownloadedTorrentsUsecase>(),
      getGroupedTorrentsUsecase = serviceLocator<GetGroupedTorrentsUsecase>(),
      deleteTorrentUsecase = serviceLocator<DeleteTorrentUsecase>(),
      deleteReleaseGroupUsecase = serviceLocator<DeleteReleaseGroupUsecase>(),
      super(DownloadedTorrentInitial()) {
    on<LoadDownloadedTorrents>(_onLoadDownloadedTorrents);
    on<RefreshDownloadedTorrents>(_onRefreshDownloadedTorrents);
    on<DeleteTorrent>(_onDeleteTorrent);
    on<DeleteReleaseGroup>(_onDeleteReleaseGroup);
  }

  Future<void> _onLoadDownloadedTorrents(
    LoadDownloadedTorrents event,
    Emitter<DownloadedTorrentState> emit,
  ) async {
    emit(DownloadedTorrentLoading());

    try {
      final List<ReleaseGroupEntity> releaseGroups =
          await getGroupedTorrentsUsecase.call();

      final List<DownloadedTorrentEntity> allTorrents =
          await getAllDownloadedTorrentsUsecase.call();

      emit(
        DownloadedTorrentLoaded(
          releaseGroups: releaseGroups,
          allTorrents: allTorrents,
        ),
      );
    } catch (e) {
      emit(DownloadedTorrentError(errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshDownloadedTorrents(
    RefreshDownloadedTorrents event,
    Emitter<DownloadedTorrentState> emit,
  ) async {
    add(LoadDownloadedTorrents());
  }

  Future<void> _onDeleteTorrent(
    DeleteTorrent event,
    Emitter<DownloadedTorrentState> emit,
  ) async {
    try {
      await deleteTorrentUsecase.call(event.torrentId);
      add(RefreshDownloadedTorrents());
    } catch (e) {
      emit(
        DownloadedTorrentError(errorMessage: 'Failed to delete torrent: $e'),
      );
    }
  }

  Future<void> _onDeleteReleaseGroup(
    DeleteReleaseGroup event,
    Emitter<DownloadedTorrentState> emit,
  ) async {
    try {
      await deleteReleaseGroupUsecase.call(event.releaseGroupName);
      add(RefreshDownloadedTorrents());
    } catch (e) {
      emit(
        DownloadedTorrentError(
          errorMessage: 'Failed to delete release group: $e',
        ),
      );
    }
  }
}
