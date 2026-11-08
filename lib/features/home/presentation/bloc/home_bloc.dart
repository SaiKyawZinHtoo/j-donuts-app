part of '../../home_import.dart';

/// Loads the home bundle and tracks connectivity so the UI can show an
/// offline banner without blanking already-loaded content.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeUseCase getHomeUseCase;
  final ConnectivityService connectivity;

  StreamSubscription<bool>? _connectivitySub;
  bool _isOffline = false;

  HomeBloc({required this.getHomeUseCase, required this.connectivity})
      : super(const HomeLoading()) {
    on<HomeRequested>(_onRequested);
    on<HomeRefreshRequested>(_onRequested);
    on<ConnectivityChanged>(_onConnectivityChanged);

    _connectivitySub = connectivity.onStatusChanged.listen(
      (isOnline) => add(ConnectivityChanged(isOnline)),
    );
  }

  Future<void> _onRequested(HomeEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    _isOffline = !(await connectivity.isOnline());
    final result = await getHomeUseCase.call();
    if (result is Ok<HomeBundle>) {
      emit(HomeLoaded(result.value, _isOffline));
    } else {
      emit(HomeError((result as Err<HomeBundle>).message));
    }
  }

  void _onConnectivityChanged(ConnectivityChanged event, Emitter<HomeState> emit) {
    _isOffline = !event.isOnline;
    final current = state;
    if (current is HomeLoaded) {
      emit(HomeLoaded(current.data, _isOffline, sectionErrors: current.sectionErrors));
    }
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}
