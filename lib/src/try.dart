import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';

Validation<T> Try<T>(T Function () tryBlock) {
  try
  {
    return Valid<T>(tryBlock());
  }
  catch(e)
  {
    if(e is Error)
    {
      return Fail.withError(e).toInvalid<T>();
    }
    else if(e is Exception) {
      return Fail.withException(e).toInvalid<T>();
    }
    
    return Fail.withError(Error(), message: 'Unknown error').toInvalid<T>();
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
        else if(err is String)
        {
          return Invalid<T>([Fail.withError(ArgumentError(err))]);
        }

        return Fail.withError(Error(), message: 'Unknown error').toInvalid<T>();
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
        else if(err is String)
        {
          return Invalid<T>([Fail.withError(ArgumentError(err))]);
        }

        return Fail.withError(Error(), message: 'Unknown error').toInvalid<T>();
      });
}
