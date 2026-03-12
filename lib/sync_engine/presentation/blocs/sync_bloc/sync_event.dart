import 'package:equatable/equatable.dart';

abstract class SyncEvent extends Equatable {}

class StartSync extends SyncEvent {
  @override
  List<Object?> get props => [];
}
