import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SyncStatus { waiting, updating, synced }

class SyncCubit extends Cubit<SyncStatus> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  SyncCubit() : super(SyncStatus.synced) {
    _init();
  }

  Future<void> _init() async {
    // Check initial state immediately on startup
    final result = await _connectivity.checkConnectivity();
    _handleConnectivity(result);

    // Then listen for future changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivity,
    );
  }

  void _handleConnectivity(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.none)) {
      emit(SyncStatus.waiting);
    } else if (state == SyncStatus.waiting) {
      // Only go back to 'synced' if we were previously 'waiting'
      emit(SyncStatus.synced);
    }
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
