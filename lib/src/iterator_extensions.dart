import 'package:functional_dart/src/option.dart';

extension FunctionalIterable<T> on Iterable<T> {
  Iterable<R> bind<R>(Iterable<R> Function(T t) f) sync* {
    for (var e in this) {
      for (var r in f(e)) {
        yield r;
      }
    }
  }

  Iterable<R> flatMap<R>(Option<R> Function(T t) f) =>
      bind((t) => f(t).asIterable());
}
