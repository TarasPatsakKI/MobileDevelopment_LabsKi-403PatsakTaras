import 'dart:async';
import 'package:flutter/material.dart';
import '../domain/services/connectivity_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _service = ConnectivityService();
  bool _isConnected = true;
  StreamSubscription? _sub;
  Timer? _periodicTimer;

  bool get isConnected => _isConnected;

  ConnectivityProvider() {
    _init();
  }

  Future<void> _init() async {
    await _updateConnectionStatus();

    _sub = _service.onConnectivityChanged.listen((_) async {
      await _updateConnectionStatus();
    });

    _periodicTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _updateConnectionStatus();
    });
  }

  Future<void> _updateConnectionStatus() async {
    try {
      final connected = await _service.checkConnection();
      if (connected != _isConnected) {
        _isConnected = connected;
        notifyListeners();
      }
    } catch (_) {
      _isConnected = false;
      notifyListeners();
    }
  }

  Future<bool> checkConnection() => _service.checkConnection();

  @override
  void dispose() {
    _sub?.cancel();
    _periodicTimer?.cancel();
    super.dispose();
  }
}
