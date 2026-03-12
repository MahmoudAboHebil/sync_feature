import 'package:equatable/equatable.dart';
import 'package:sync_feature/core/error/failure.dart';
import 'package:sync_feature/core/error/sync_response.dart';

abstract class SyncState extends Equatable {}

class SyncInitial extends SyncState {
  @override
  List<Object?> get props => [];
}

class SyncInProgress extends SyncState {
  @override
  List<Object?> get props => [];
}

class SyncDone extends SyncState {
  final List<SyncResponse> results;
  SyncDone(this.results);
  @override
  List<Object?> get props => [...results];
}

class SyncError extends SyncState {
  final Failure failure;
  SyncError(this.failure);
  @override
  List<Object?> get props => [failure];
}
