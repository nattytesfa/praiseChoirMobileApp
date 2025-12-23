import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SyncStatus { waiting, updating, synced }

class SyncCubit extends Cubit<SyncStatus> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  SyncCubit() : super(SyncStatus.synced) {
    // Listen for internet changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result.contains(ConnectivityResult.none)) {
        emit(SyncStatus.waiting); // "Waiting for network..."
      } else {
        // When internet returns, it's usually "Synced" unless a sync is triggered
        emit(SyncStatus.synced); 
      }
    });
  }

  // Call this from your SongRepository when starting/ending a fetch
  void setSyncing(bool isSyncing) {
    if (state != SyncStatus.waiting) {
      emit(isSyncing ? SyncStatus.updating : SyncStatus.synced);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}