extension ListExtensions<T> on List<T> {
  List<T> setFixedLengthWithDefaultValue(int length, T defaultValue) {
    if (length < 0) return [];
    if (this.length == length) return this;
    if (this.length < length) {
      return List<T>.from(this)..addAll(List<T>.filled(length - this.length, defaultValue));
    } else {
      return List<T>.from(this).sublist(0, length);
    }
  }
}
