part of '../../home_import.dart';

/// Events driving the home screen.
sealed class HomeEvent {
  const HomeEvent();
}

final class HomeRequested extends HomeEvent {
  const HomeRequested();
}

final class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

final class ConnectivityChanged extends HomeEvent {
  final bool isOnline;
  const ConnectivityChanged(this.isOnline);
}
