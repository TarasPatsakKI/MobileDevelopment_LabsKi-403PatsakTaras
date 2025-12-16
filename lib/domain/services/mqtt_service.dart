import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  MqttClient? _client;
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  final StreamController<MqttConnectionState> _connectionStateController =
      StreamController<MqttConnectionState>.broadcast();

  StreamSubscription? _updatesSubscription;

  Stream<String> get messageStream => _messageController.stream;
  Stream<MqttConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;

  Future<bool> connect({
    String broker = 'broker.hivemq.com',
    int port = 1883,
    String? clientId,
  }) async {
    final id = clientId ?? 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';

    // Use WebSocket for web, TCP for other platforms
    if (kIsWeb) {
      // Use HiveMQ public WebSocket secure endpoint (port 8884)
      const webBroker = 'broker.hivemq.com';
      const wsUrl = 'wss://$webBroker/mqtt';
      final browserClient = MqttBrowserClient(wsUrl, id);
      browserClient.port = 8884; // Explicitly set WSS port
      browserClient.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
      _client = browserClient;
    } else {
      _client = MqttServerClient(broker, id);
      (_client as MqttServerClient).port = port;
    }

    _client!.logging(on: false);
    _client!.keepAlivePeriod = 20;
    _client!.autoReconnect = true;

    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    _client!.onAutoReconnect = _onAutoReconnect;
    _client!.onAutoReconnected = _onAutoReconnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(id)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client!.connectionMessage = connMessage;

    try {
      debugPrint('MQTT: Attempting to connect...');
      debugPrint('MQTT: Platform is web: $kIsWeb');
      if (kIsWeb) {
        debugPrint('MQTT: Using WebSocket: wss://broker.hivemq.com:8884/mqtt');
        try {
          debugPrint('MQTT: Port explicitly set to: ${(_client as MqttBrowserClient).port}');
        } catch (_) {}
      } else {
        debugPrint('MQTT: Using TCP broker: $broker:$port');
      }

      await _client!.connect();

      debugPrint('MQTT: Connection status: ${_client!.connectionStatus?.state}');

      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        debugPrint('MQTT: Successfully connected!');
        _connectionStateController.add(MqttConnectionState.connected);
        _setupUpdatesListener();
        return true;
      } else {
        debugPrint('MQTT: Connection failed - state: ${_client!.connectionStatus?.state}');
        debugPrint('MQTT: Return code: ${_client!.connectionStatus?.returnCode}');
        _client!.disconnect();
        _connectionStateController.add(MqttConnectionState.disconnected);
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('MQTT: Connection error: $e');
      debugPrint('MQTT: Stack trace: $stackTrace');
      _client?.disconnect();
      _connectionStateController.add(MqttConnectionState.faulted);
      return false;
    }
  }

  void _setupUpdatesListener() {
    _updatesSubscription?.cancel();
    if (_client?.updates == null) return;
    _updatesSubscription = _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (final message in messages) {
        final recMess = message.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _messageController.add(payload);
      }
    });
  }

  void subscribe(String topic) {
    if (_client == null || !isConnected) return;
    _client!.subscribe(topic, MqttQos.atMostOnce);
  }

  void publish(String topic, String message) {
    if (_client == null || !isConnected) return;
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }

  void disconnect() {
    try {
      _updatesSubscription?.cancel();
      _client?.disconnect();
      _connectionStateController.add(MqttConnectionState.disconnected);
    } catch (_) {}
  }

  void _onConnected() {
    debugPrint('MQTT: onConnected');
  }

  void _onDisconnected() {
    debugPrint('MQTT: onDisconnected');
  }

  void _onAutoReconnect() {
    debugPrint('MQTT: onAutoReconnect');
  }

  void _onAutoReconnected() {
    debugPrint('MQTT: onAutoReconnected');
  }

  void dispose() {
    _updatesSubscription?.cancel();
    _messageController.close();
    _connectionStateController.close();
    _client = null;
  }
}
