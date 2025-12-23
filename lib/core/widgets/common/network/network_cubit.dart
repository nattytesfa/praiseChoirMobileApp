import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { connected, disconnected }

class NetworkCubit extends Cubit<NetworkStatus> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  NetworkCubit() : super(NetworkStatus.connected) {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result.contains(ConnectivityResult.none)) {
        emit(NetworkStatus.disconnected);
      } else {
        emit(NetworkStatus.connected);
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}