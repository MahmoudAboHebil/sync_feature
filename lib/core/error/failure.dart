import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});
  @override
  List<Object> get props => [message];

  @override
  String toString() {
    return 'Failure  { message: $message }';
  }
}

class InvalidValueFailure extends Failure {
  const InvalidValueFailure({required super.message});
  @override
  String toString() {
    return '''Failure (InvalidValueFailure) \n { message: $message }''';
  }
}

class ProcessingFailure extends Failure {
  const ProcessingFailure({required super.message});

  @override
  String toString() {
    return '''Failure (ProcessingFailure) \n { message: $message }''';
  }
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}
