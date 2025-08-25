List<T> copyWithReplacement<T>(
  List<T> original,
  int i,
  T Function(T) transform,
) {
  if (i < 0 || i >= original.length) {
    throw RangeError.index(i, original, 'i');
  }

  final copy = List<T>.from(original);
  copy[i] = transform(original[i]);
  return copy;
}
