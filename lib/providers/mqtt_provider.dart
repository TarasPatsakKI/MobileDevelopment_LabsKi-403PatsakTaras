import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../domain/services/mqtt_service.dart';

class SensorData {
  final String value;
  final DateTime timestamp;
  final String topic;

  SensorData({required this.value, required this.timestamp, required this.topic});
}

class MqttProvider extends ChangeNotifier {
  final MqttService _mqttService = MqttService();

  MqttConnectionState _connectionState = MqttConnectionState.disconnected;
  final List<SensorData> _sensorHistory = [];
  String _currentValue = '--';
  String _currentTopic = 'sensor/temperature';
  String _broker = 'broker.hivemq.com';
  int _port = 1883;

  StreamSubscription<String>? _messageSubscription;
  StreamSubscription<MqttConnectionState>? _connectionSubscription;

  MqttConnectionState get connectionState => _connectionState;
  List<SensorData> get sensorHistory => List.unmodifiable(_sensorHistory);
  String get currentValue => _currentValue;
  String get currentTopic => _currentTopic;
  String get broker => _broker;
  int get port => _port;
  bool get isConnected => _connectionState == MqttConnectionState.connected;

  MqttProvider() {
    _connectionSubscription = _mqttService.connectionStateStream.listen((state) {
      _connectionState = state;
      notifyListeners();
    });

    _messageSubscription = _mqttService.messageStream.listen((message) {
      _currentValue = message;
      _sensorHistory.insert(0, SensorData(value: message, timestamp: DateTime.now(), topic: _currentTopic));
      if (_sensorHistory.length > 50) _sensorHistory.removeLast();
      notifyListeners();
    });
  }

  Future<bool> connect({String? broker, int? port, String? topic}) async {
    if (broker != null) _broker = broker;
    if (port != null) _port = port;
    if (topic != null) _currentTopic = topic;

    final success = await _mqttService.connect(broker: _broker, port: _port);

    if (success) {
      _mqttService.subscribe(_currentTopic);
    }

    return success;
  }

  void disconnect() {
    _mqttService.disconnect();
  }

  void publishTest() {
    final value = (20 + (DateTime.now().millisecond % 10) / 10).toStringAsFixed(2);
    _mqttService.publish(_currentTopic, value);
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _mqttService.dispose();
    super.dispose();
  }
}
