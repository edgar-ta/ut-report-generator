List<T> copyWithout<T>(List<T> list, T element) {
  return list.where((e) => e != element).toList();
}
