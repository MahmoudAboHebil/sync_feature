import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});
  @override
  List<Object> get props => [message];
}

class InvalidValueFailure extends Failure {
  const InvalidValueFailure({required super.message});
}

class ProcessingFailure extends Failure {
  const ProcessingFailure({required super.message});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}
