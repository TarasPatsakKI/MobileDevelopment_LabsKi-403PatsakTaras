import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<dynamic> get onConnectivityChanged => _connectivity.onConnectivityChanged;
  Future<bool> checkConnection() async {
    try {
      final dynamic result = await _connectivity.checkConnectivity();
      if (result is List) {
        return result.any((r) => r != ConnectivityResult.none);
      }
      if (result is ConnectivityResult) {
        return result != ConnectivityResult.none;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
