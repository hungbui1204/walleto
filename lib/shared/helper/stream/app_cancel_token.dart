class AppCancelToken {
  AppCancelToken();

  bool _isCancelled = false;
  final List<void Function()> _listeners = [];

  bool get isCancelled => _isCancelled;

  void cancel() {
    if (_isCancelled) {
      return;
    }

    _isCancelled = true;
    final listeners = List<void Function()>.of(_listeners);
    _listeners.clear();
    for (final listener in listeners) {
      listener();
    }
  }

  void whenCancel(void Function() listener) {
    if (_isCancelled) {
      listener();
      return;
    }

    _listeners.add(listener);
  }
}
