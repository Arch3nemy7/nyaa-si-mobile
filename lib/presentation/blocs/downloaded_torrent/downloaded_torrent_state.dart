part of 'downloaded_torrent_bloc.dart';

sealed class DownloadedTorrentState extends Equatable {
  const DownloadedTorrentState();
  
  @override
  List<Object> get props => [];
}

final class DownloadedTorrentInitial extends DownloadedTorrentState {}
