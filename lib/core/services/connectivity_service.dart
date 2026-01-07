import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ConnectivityResult _currentStatus = ConnectivityResult.none;
  bool _isConnected = false;

  ConnectivityResult get currentStatus => _currentStatus;
  bool get isConnected => _isConnected;

  ConnectivityService() {
    _init();
  }

  void _init() async {
    // Get initial status
    await _checkConnectivity();

    // Listen for changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(result);
    } catch (e) {
      //
    }
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _currentStatus = result;
    _isConnected = result != ConnectivityResult.none;
    notifyListeners();
  }

  Future<bool> checkInternetAccess() async {
    // This is a basic check - you might want to implement a more robust check
    // by trying to connect to a reliable server
    try {
      final result = await _connectivity.checkConnectivity();
      final first = result.isNotEmpty ? result.first : ConnectivityResult.none;
      return first != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }

  Future<List<ConnectivityResult>> getCurrentStatus() async {
    return await _connectivity.checkConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

// Singleton instance for easy access
final connectivityService = ConnectivityService();

// Helper functions
class NetworkUtils {
  static String getConnectionTypeName(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }

  static bool isConnectionStable(ConnectivityResult result) {
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.mobile;
  }

  static bool isConnectionExpensive(ConnectivityResult result) {
    return result == ConnectivityResult.mobile;
  }
}
