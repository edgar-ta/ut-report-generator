Future<T> waitAtLeast<T>(Duration duration, Future<T> future) {
  return Future.wait([
    Future.delayed(duration),
    future,
  ]).then((values) => values[1] as T);
}
