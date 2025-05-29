import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'downloaded_torrent_event.dart';
part 'downloaded_torrent_state.dart';

class DownloadedTorrentBloc extends Bloc<DownloadedTorrentEvent, DownloadedTorrentState> {
  DownloadedTorrentBloc() : super(DownloadedTorrentInitial()) {
    on<DownloadedTorrentEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
