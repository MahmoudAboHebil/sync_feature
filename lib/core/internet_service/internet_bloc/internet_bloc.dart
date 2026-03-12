import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'internet_event.dart';
import 'internet_state.dart';

class InternetBloc extends Bloc<InternetEvent, InternetState> {
  StreamSubscription? _subscription;

  InternetBloc() : super(InternetInitial()) {
    // عند استقبال أي event جديد
    on<InternetStatusChanged>((event, emit) {
      if (event.isConnected) {
        emit(InternetConnected());
      } else {
        emit(InternetDisconnected());
      }
    });

    _subscription = InternetConnection().onStatusChange.listen((status) async {
      final bool isConnected = await InternetConnection().hasInternetAccess;
      add(InternetStatusChanged(isConnected));
    });

    // تحقق أول مرة فور إنشاء الـ Bloc
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final connected = await InternetConnection().hasInternetAccess;
    add(InternetStatusChanged(connected));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
