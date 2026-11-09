part of '../../home_import.dart';

sealed class HomeState {
  const HomeState();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  final HomeBundle data;
  final bool isOffline;

  /// Section id -> error message, for sections that failed to load without
  /// blanking the rest of the screen. Empty until a per-section data source
  /// exists (currently `GetHomeUseCase` loads the whole bundle or nothing).
  final Map<String, String?> sectionErrors;

  const HomeLoaded(this.data, this.isOffline, {this.sectionErrors = const {}});
}

final class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
}
