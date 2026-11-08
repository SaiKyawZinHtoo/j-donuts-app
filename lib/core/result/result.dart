/// Generic result type for repository/use-case return values.
///
/// No Flutter dependency — pure Dart so it can be used in domain/data layers.
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.err(String message) = Err<T>;

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;
}

final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

final class Err<T> extends Result<T> {
  final String message;
  const Err(this.message);
}
