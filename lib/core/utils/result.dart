sealed class Result<T, E> {
  const Result();
  R match<R>({required R Function(T) ok, required R Function(E) err}) =>
      switch (this) { Ok<T, E>(value: final v) => ok(v), Err<T, E>(error: final e) => err(e) };
  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;
  T? get valueOrNull => this is Ok<T, E> ? (this as Ok<T, E>).value : null;
  E? get errorOrNull => this is Err<T, E> ? (this as Err<T, E>).error : null;
}

class Ok<T, E> extends Result<T, E> {
  final T value;
  const Ok(this.value);
}

class Err<T, E> extends Result<T, E> {
  final E error;
  const Err(this.error);
}
