import 'package:gl_functional/src/fail.dart';

Validation<T> Valid<T>(T value) => Validation.valid(value);
Validation<T> Invalid<T>(Iterable<Fail> failures) => Validation.invalid(failures);

class Validation<T> {
  final Iterable<Fail> _failures;
  final T? _value;
  bool get isValid => _failures.isEmpty;

  Validation.valid(T value)
      : _value = value,
        _failures = <Fail>[];
  Validation.invalid(Iterable<Fail> failures)
      : _failures = failures,
        _value = null;

  TR fold<TR>(TR Function(Iterable<Fail> failures) invalid, 
              TR Function(T val) valid) 
  {
    return isValid ? valid(_value!) : invalid(_failures);
  }
      

  Iterable<T> asIterable() sync* {
    if (isValid) {
      yield _value!;
    }
  }

  Validation<R> map<R>(R Function(T val) f) =>
      fold((err) => Invalid<R>(err), (v) => Valid(f(v)));

  Validation<void> forEach(void Function(T val) action) => map(action);

  Validation<T> andThen(void Function(T t) action) {
    forEach(action);
    return this;
  }

  Validation<R> bind<R>(Validation<R> Function(T val) f) =>
      fold((fails) => Invalid<R>(fails), (v) => f(v));


  Future<Validation<T>> toFuture() => Future(() => this);

  static Validation<T> Try<T>(T Function() f, {String failMessage = ''}) {
    try{
      return Valid(f());
    }
    catch (e)
    {
      final fail = e is Exception ? Fail.withException(failMessage, exception: e) 
                                  : Fail.withError(failMessage, error: e as Error);
      return Invalid<T>([fail]);
    }
  }
 
 static Future<Validation<T>> tryFuture<T>(Future<T> Function() f) 
        => f().then(Valid)
              .catchError((err) {
                if (err is Exception) {
                  return Invalid<T>([Fail.withException('', exception: err)]);
                }
                else if (err is Error)
                {
                  return Invalid<T>([Fail.withError('', error: err)]);
                }
              });
}

extension FutureValidation on Future<Validation> {
  Future<TR> fold<TR, T>(TR Function(Iterable<Fail> failures) invalid, 
              TR Function(T val) valid) 
  {
    return then(
            (value) => 
              value.fold(
                (failures) => invalid(failures), 
                (val) => valid(val)));
  }


  Future<Validation<R>> map<R, T>(R Function(T t) f) =>
      fold((err) => Invalid<R>(err), (v) => Valid(f(v! as T)));

  Future<Validation<R>> bind<R, T>(Validation<R> Function(T t) f) =>
      fold((fail) => Invalid<R>(fail), (v) => f(v! as T));

  Future<TR> foldFuture<TR, T>(Future<TR> Function(Iterable<Fail> failures) invalid, 
                                                  Future<TR> Function(T val) valid) 
  {
    
    return then((value) => value.fold((failures) => invalid(failures).then((value) => value), 
                                      (val)       => valid(val).then((value) => value)));
  }


  Future<Validation<R>> mapFuture<R, T>(Future<R> Function(T t) f) =>
      foldFuture((err) => Invalid<R>(err).toFuture(), 
                 (v)   => f(v! as T).then((value) => Valid(value)));

  Future<Validation<R>> bindFuture<R, T>(Future<Validation<R>> Function(T t) f) =>
      foldFuture((fail) => Invalid<R>(fail).toFuture(), (v) => f(v! as T));
}