import 'dart:async';

/// Утилита для debounce (задержки выполнения функции).
///
/// Предотвращает выполнение функции слишком часто.
/// Функция будет выполнена только после того, как пройдет указанное время
/// без новых вызовов.
class Debounce {
  Debounce(this.duration);
  final Duration duration;
  Timer? _timer;

  /// Выполняет функцию с задержкой.
  ///
  /// Если функция вызывается снова до истечения времени задержки,
  /// предыдущий вызов отменяется и таймер перезапускается.
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Отменяет ожидающий вызов функции.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Освобождает ресурсы.
  void dispose() {
    cancel();
  }
}

/// Создает функцию с debounce.
///
/// [duration] - время задержки перед выполнением функции
/// [action] - функция для выполнения
///
/// Возвращает функцию, которую можно вызывать многократно,
/// но она будет выполнена только после истечения времени задержки.
Function() debounce(
  Duration duration,
  void Function() action,
) {
  final debouncer = Debounce(duration);
  return () => debouncer(action);
}

