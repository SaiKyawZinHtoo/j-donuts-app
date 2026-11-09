part of '../../home_import.dart';

/// Events driving the home screen.
sealed class HomeEvent {
  const HomeEvent();
}

final class HomeRequested extends HomeEvent {
  const HomeRequested();
}

final class HomeRefreshRequested extends HomeEvent {
  /// Completed when the refresh finishes, so pull-to-refresh can await it.
  final Completer<void>? done;
  const HomeRefreshRequested({this.done});
}

final class ConnectivityChanged extends HomeEvent {
  final bool isOnline;
  const ConnectivityChanged(this.isOnline);
}
