import 'package:functional_dart/functional_dart.dart';

Validation<T> Try<T>(T Function () tryBlock) {
  try
  {
    return Valid<T>(tryBlock());
  }
  catch(e)
  {
    if(e is Error)
    {
      return Fail.withError(e).toInvalid();
    }
    else if(e is Exception) {
      return Fail.withException(e).toInvalid();
    }
    
    return Fail.withError(Error(), message: 'Unknown error').toInvalid();
  }
} 

extension TryExt on Future {
  Future<Validation<T>> tryCatch<T>() =>
      then((value) => Valid<T>(value)).catchError((err) {
        if (err is Exception) {
          return Invalid<T>([Fail.withException(err)]);
        } else if (err is Error) {
          return Invalid<T>([Fail.withError(err)]);
        }
      });
}

extension TryFutureValidation on Future<Validation> {
  Future<Validation<T>> tryCatch<T>() =>
      then((value) => value as Validation<T>).catchError((err) {
        if (err is Exception) {
          return Invalid<T>([Fail.withException(err)]);
        } else if (err is Error) {
          return Invalid<T>([Fail.withError(err)]);
        }
      });
}
