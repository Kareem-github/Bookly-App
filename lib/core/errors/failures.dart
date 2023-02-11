import 'package:dio/dio.dart';

abstract class Failures {
  final String errorMessage;

  Failures(this.errorMessage);
}

class ServerFailure extends Failures {
  ServerFailure(super.errorMessage);

  factory ServerFailure.fromDioError(DioError dioError) {
    switch (dioError.type) {
      case DioErrorType.connectTimeout:
        return ServerFailure('Connection timeout with API server');
      case DioErrorType.sendTimeout:
        return ServerFailure('Send timeout with API server');
      case DioErrorType.receiveTimeout:
        return ServerFailure('Recieve timeout with API server');
      case DioErrorType.response:
        return ServerFailure.fromResponse(
            dioError.response!.statusCode!, dioError.response!.data);
      case DioErrorType.cancel:
        return ServerFailure('Request to API server was cancelled');
      case DioErrorType.other:
        if (dioError.message.contains('SocketException')) {
          return ServerFailure('No internet connection');
        } else {
          return ServerFailure('Unexpected error, please try again later');
        }
      default:
        return ServerFailure('Oops, there was an error, plase try again later');
    }
  }

  factory ServerFailure.fromResponse(int statusCode, dynamic response) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return ServerFailure(response['error']['message']);
    } else if (statusCode == 404) {
      return ServerFailure('Your request is not found, please try again later');
    } else if (statusCode == 500) {
      return ServerFailure('Server error, please try again later');
    } else {
      return ServerFailure('Oops, there was an error, plase try again later');
    }
  }
}
