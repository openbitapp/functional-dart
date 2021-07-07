import 'dart:async';
import 'dart:io';

import 'package:gl_functional/gl_functional.dart';
import 'package:gl_functional/src/either.dart';
import 'package:gl_functional/src/option.dart';


class Fail {
  final String message;
  final Option<Either<Error, Exception>> _failedWith;

  Fail(this.message) : _failedWith = None();
  Fail.withError(this.message, {required Error error})
      : _failedWith = Some(Left<Error, Exception>(error));
      
  Fail.withException(this.message, {required Exception exception})
      : _failedWith = Some(Right<Error, Exception>(exception));

  String get innerMessage =>
      _failedWith.fold(() => '', (some) => some.fold((l) => l.toString(), (r) => r.toString()));

  T fold<T>(T Function() noneF, T Function(Error err) errF,
      T Function(Exception exc) excF) {
    return _failedWith.fold(() => noneF(),
        (some) => some.fold((error) => errF(error), (exc) => excF(exc)));
  }

  bool isExceptionOfType(Type t) =>
      fold(() => false, (err) => false, (exc) => exc.runtimeType == t);

  String fromHttpExceptions() {
    return fold(
        () => 'Nessun errore.',
        (err) =>
            "Siamo spiacenti: c'è stato un errore imprevisto durante il recupero dei dati dal server.",
        (exc) {
      if (exc is TimeoutException) {
        return 'Siamo spiacenti: i nostri server sono occupati. Riprovate più tardi';
      }

      if (exc is HttpException) {
        return 'Siamo spiacenti: in questo momento i dati non sono disponibili. Riprovate più tardi.';
      }

      if (exc is SocketException) {
        return 'Impossibile raggiungere il server. Controllare la connsessione internet.';
      }

      if (exc is BadResponseException) {
        return 'Siamo spiacenti: in questo momento i dati non sono disponibili. Riprovate più tardi.';
      }

      if (exc is FormatException) {
        return 'Siamo spiacenti: in questo momento i dati non sono disponibili. Riprovate più tardi.';
      }

      return "Siamo spiacenti: c'è stato un errore imprevisto durante il recupero dei dati dal server.";
    });
  }

  factory Fail.fromHttpExceptions(Exception error) {
    var message = '';

    if (error is TimeoutException) {
      message = 'Siamo spiacenti: i nostri server sono occupati. Riprovate più tardi';
    }
    else if (error is HttpException) {
      message = 'Siamo spiacenti: in questo momento i dati non sono disponibili. Riprovate più tardi.';
    }
    else if (error is SocketException) {
      message = 'Impossibile raggiungere il server. Controllare la connsessione internet.';
    }
    else if (error is BadResponseException) {
      message = 'Siamo spiacenti: in questo momento i dati non sono disponibili. Riprovate più tardi.';
    }
    else if (error is FormatException) {
      message = 'Siamo spiacenti: in questo momento i dati non sono disponibili. Riprovate più tardi.';
    }
    else
    {
      message = "Siamo spiacenti: c'è stato un errore imprevisto durante il recupero dei dati dal server.";
    }
    return error.toFail(message);
  }

  Iterable<Fail> toIterable () => [this];

  Validation<T> toInvalid<T> () => toIterable().toInvalid<T>();
}

class BadResponseException implements IOException {
  final String message;
  int statusCode;

  BadResponseException(int statusCode) : message = 'Bad response. Response code: $statusCode', statusCode = statusCode;
  BadResponseException.fromString (this.message) : statusCode = -1 {
    final regExp =  RegExp(r'\d+',
                              caseSensitive: false,
                              multiLine: false);
    
    final match = regExp.stringMatch(message);
    if (match != null)
    {     
      statusCode = int.parse(match);
    }
  }

  @override
  String toString() => message;
}

extension ExceptionToFailExtension on Exception {
  Fail toFail([String message = '']) => Fail.withException(message, exception: this);
  Validation<T> toInvalid<T> () => toFail ().toInvalid<T>();
}

extension ErrorToFailExtension on Error {
  Fail toFail([String message = '']) => Fail.withError(message, error: this);
  Validation<T> toInvalid<T> () => toFail ().toInvalid<T>();
}

extension IterabeFailExtension on Iterable<Fail>
{
  Validation<T> toInvalid<T> () => Invalid<T> (this);

}