List<T> reorderElement<T>(List<T> list, int oldIndex, int newIndex) {
  // Some edge-cases to consider:
  // - When both indices are the same (just return a copy of the list)
  // - When the list is empty
  // - When the list has one element

  if (newIndex > oldIndex + 1) {
    newIndex -= 1;
  }
  var newList = <T>[];
  for (var i = 0; i < list.length; i++) {
    if (i != oldIndex) {
      var argument = list[i];
      newList.add(argument);
    }
  }

  if (newIndex == newList.length) {
    newList.add(list[oldIndex]);
  } else {
    newList.insert(newIndex, list[oldIndex]);
  }

  return newList;
}
