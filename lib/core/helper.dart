class Helper {
  static Iterable<List<T>> chunk<T>(List<T> list, int size) sync* {
    for (int i = 0; i < list.length; i += size) {
      yield list.sublist(i, i + size > list.length ? list.length : i + size);
    }
  }
}
