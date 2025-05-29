import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/nyaa_torrent_entity.dart';
import '../../../domain/usecases/download_torrent_usecase.dart';
import '../../dependency_injection.dart';

part 'torrent_download_event.dart';
part 'torrent_download_state.dart';

class TorrentDownloadBloc
    extends Bloc<TorrentDownloadEvent, TorrentDownloadState> {
  final DownloadTorrentUsecase _downloadTorrentUsecase;

  TorrentDownloadBloc()
    : _downloadTorrentUsecase = serviceLocator<DownloadTorrentUsecase>(),
      super(const TorrentDownloadInitial()) {
    on<DownloadTorrentEvent>(_onDownloadTorrent);
  }

  Future<void> _onDownloadTorrent(
    DownloadTorrentEvent event,
    Emitter<TorrentDownloadState> emit,
  ) async {
    final NyaaTorrentEntity torrent = event.torrent;

    emit(TorrentDownloading(torrentId: torrent.id));

    try {
      final String filePath = await _downloadTorrentUsecase.call(
        torrentId: torrent.id,
        releaseGroup: torrent.releaseGroup,
      );

      emit(TorrentDownloadSuccess(torrentId: torrent.id, filePath: filePath));
    } catch (e) {
      emit(TorrentDownloadFailure(torrentId: torrent.id, error: e.toString()));
    }
  }
}
