List<T> copyWithAdded<T>(List<T> list, T element) {
  return List<T>.from(list)..add(element);
}
