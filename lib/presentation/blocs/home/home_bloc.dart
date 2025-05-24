import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nyaa_si_mobile/domain/entities/nyaa_torrent_entities.dart';
import 'package:nyaa_si_mobile/domain/usecases/fetch_torrents_usecase.dart';
import 'package:nyaa_si_mobile/presentation/dependency_injection.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchTorrentsUseCase _fetchTorrentsUseCase;

  HomeBloc()
    : _fetchTorrentsUseCase = serviceLocator<FetchTorrentsUseCase>(),
      super(HomeInitial()) {
    on<FetchTorrentsEvent>(_onFetchTorrents);
    on<RefreshTorrentsEvent>(_onRefreshTorrents);
  }

  Future<void> _onFetchTorrents(
    FetchTorrentsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(TorrentsLoadingState());
    try {
      final List<NyaaTorrentEntity> torrents = await _fetchTorrentsUseCase.call(
        page: event.page,
        query: event.query,
        filter: event.filter,
        category: event.category,
        sort: event.sort,
        order: event.order,
      );
      emit(TorrentsLoadedState(torrents: torrents));
    } catch (e) {
      emit(TorrentsErrorState(error: e.toString()));
    }
  }

  Future<void> _onRefreshTorrents(
    RefreshTorrentsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(TorrentsLoadingState());
    try {
      final List<NyaaTorrentEntity> torrents = await _fetchTorrentsUseCase();
      emit(TorrentsLoadedState(torrents: torrents));
    } catch (e) {
      emit(TorrentsErrorState(error: e.toString()));
    }
  }
}
