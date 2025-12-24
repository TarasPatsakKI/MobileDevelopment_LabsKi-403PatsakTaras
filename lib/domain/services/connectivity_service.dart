import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<dynamic> get onConnectivityChanged => _connectivity.onConnectivityChanged;
  Future<bool> checkConnection() async {
    try {
      final dynamic result = await _connectivity.checkConnectivity();

      // If there is no connection reported by the platform, return false early
      if (result is List) {
        if (!result.any((r) => r != ConnectivityResult.none)) return false;
      } else if (result is ConnectivityResult) {
        if (result == ConnectivityResult.none) return false;
      } else {
        return false;
      }

      // If running on web, avoid HTTP reachability due to CORS/timeouts — rely on connectivity type
      if (kIsWeb) {
        return true;
      }

      // Connectivity type exists (wifi/mobile) — verify real internet access with a lightweight HTTP request
      try {
        final uri = Uri.parse('https://clients3.google.com/generate_204');
        final resp = await http.get(uri).timeout(const Duration(seconds: 3));
        return resp.statusCode == 204 || resp.statusCode == 200;
      } catch (_) {
        return false;
      }
    } catch (_) {
      return false;
    }
  }
}
