import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/sync_all_tables_usecase.dart';
import 'package:sync_feature/sync_engine/presentation/blocs/sync_bloc/sync_event.dart';
import 'package:sync_feature/sync_engine/presentation/blocs/sync_bloc/sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncAllTablesUseCase _allTablesUseCase;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  SyncBloc(this._allTablesUseCase) : super(SyncInitial()) {
    on<StartSync>((event, emit) async {
      emit(SyncInProgress());

      final syncResult = await _allTablesUseCase.call(null);
      syncResult.fold(
        ifLeft: (err) {
          emit(SyncError(err));
        },
        ifRight: (data) {
          emit(SyncDone(data));
        },
      );
    }, transformer: droppable());

    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      final hasNetwork = !results.contains(ConnectivityResult.none);

      if (hasNetwork) {
        final bool isConnected = await InternetConnection().hasInternetAccess;

        if (isConnected) {
          add(StartSync());
        }
      }
    });
    _checkInitialConnection();
  }
  Future<void> _checkInitialConnection() async {
    final isConnected = await InternetConnection().hasInternetAccess;
    if (isConnected) add(StartSync());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
