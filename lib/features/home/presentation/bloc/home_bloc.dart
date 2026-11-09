part of '../../home_import.dart';

/// Loads the home bundle from the local database, tracks connectivity, and
/// refreshes the database from the server in the background. Content that is
/// already on screen is never blanked by a refresh.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeUseCase getHomeUseCase;
  final ConnectivityService connectivity;
  final SyncRepository? syncRepository;

  StreamSubscription<bool>? _connectivitySub;
  bool _isOffline = false;

  HomeBloc({
    required this.getHomeUseCase,
    required this.connectivity,
    this.syncRepository,
  }) : super(const HomeLoading()) {
    on<HomeRequested>(_onRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
    on<ConnectivityChanged>(_onConnectivityChanged);

    _connectivitySub = connectivity.onStatusChanged.listen(
      (isOnline) => add(ConnectivityChanged(isOnline)),
    );
  }

  Future<void> _onRequested(HomeRequested event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    _isOffline = !(await connectivity.isOnline());
    if (await _load(emit)) await _syncInBackground(emit);
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      if (state is! HomeLoaded) {
        await _onRequested(const HomeRequested(), emit);
        return;
      }
      _isOffline = !(await connectivity.isOnline());
      if (!await _syncInBackground(emit)) await _load(emit, silent: true);
    } finally {
      if (event.done?.isCompleted == false) event.done!.complete();
    }
  }

  /// Reads the database and emits it. [silent] keeps the current state on a
  /// failed read instead of showing an error.
  Future<bool> _load(Emitter<HomeState> emit, {bool silent = false}) async {
    final result = await getHomeUseCase.call();
    if (result is Ok<HomeBundle>) {
      final current = state;
      emit(
        HomeLoaded(
          result.value,
          _isOffline,
          sectionErrors: current is HomeLoaded ? current.sectionErrors : const {},
          lastSyncedAt: await syncRepository?.lastSyncedAt(),
        ),
      );
      return true;
    }
    if (!silent) emit(HomeError((result as Err<HomeBundle>).message));
    return false;
  }

  /// Returns true when a successful sync re-emitted fresh data. Failures and
  /// "not modified" emit nothing, so old data stays on screen.
  Future<bool> _syncInBackground(Emitter<HomeState> emit) async {
    final sync = syncRepository;
    if (sync == null) return false;
    final result = await sync.refresh();
    if (result is Ok<SyncOutcome> && result.value == SyncOutcome.updated) {
      return _load(emit, silent: true);
    }
    return false;
  }

  Future<void> _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<HomeState> emit,
  ) async {
    final wasOffline = _isOffline;
    _isOffline = !event.isOnline;
    final current = state;
    if (current is HomeLoaded) {
      emit(
        HomeLoaded(
          current.data,
          _isOffline,
          sectionErrors: current.sectionErrors,
          lastSyncedAt: current.lastSyncedAt,
        ),
      );
      if (wasOffline && event.isOnline) await _syncInBackground(emit);
    }
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}
