part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => <Object>[];
}

final class HomeInitial extends HomeState {}

class TorrentsLoadingState extends HomeState {}

class TorrentsLoadedState extends HomeState {
  final List<NyaaTorrentEntity> torrents;

  const TorrentsLoadedState({required this.torrents});

  @override
  List<Object> get props => <Object>[torrents];
}

class TorrentsErrorState extends HomeState {
  final String error;

  const TorrentsErrorState({required this.error});

  @override
  List<Object> get props => <Object>[error];
}
