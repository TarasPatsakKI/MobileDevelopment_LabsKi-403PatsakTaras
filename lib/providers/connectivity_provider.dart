import 'dart:async';
import 'package:flutter/material.dart';
import '../domain/services/connectivity_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _service = ConnectivityService();
  bool _isConnected = true;
  StreamSubscription? _sub;

  bool get isConnected => _isConnected;

  ConnectivityProvider() {
    _init();
  }

  Future<void> _init() async {
    _isConnected = await _service.checkConnection();
    notifyListeners();
    _sub = _service.onConnectivityChanged.listen((_) async {
      _isConnected = await _service.checkConnection();
      notifyListeners();
    });
  }

  Future<bool> checkConnection() => _service.checkConnection();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
