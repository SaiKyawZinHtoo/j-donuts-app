part of '../../rewards_import.dart';

/// Loads the rewards bundle and handles the earn/gift tab switch without
/// refetching.
class RewardsBloc extends Bloc<RewardsEvent, RewardsState> {
  final GetRewardsUseCase getRewardsUseCase;

  RewardsBloc({required this.getRewardsUseCase}) : super(const RewardsLoading()) {
    on<RewardsRequested>(_onRequested);
    on<TabChanged>(_onTabChanged);
    on<ChallengeTapped>((event, emit) {});
  }

  Future<void> _onRequested(RewardsEvent event, Emitter<RewardsState> emit) async {
    emit(const RewardsLoading());
    final result = await getRewardsUseCase.call();
    if (result is Ok<RewardsBundle>) {
      emit(RewardsLoaded(result.value, RewardsTab.earn));
    } else {
      emit(RewardsError((result as Err<RewardsBundle>).message));
    }
  }

  void _onTabChanged(TabChanged event, Emitter<RewardsState> emit) {
    final current = state;
    if (current is RewardsLoaded) {
      emit(RewardsLoaded(current.data, event.tab));
    }
  }
}
