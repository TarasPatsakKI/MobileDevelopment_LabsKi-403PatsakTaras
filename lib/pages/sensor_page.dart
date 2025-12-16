import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';
import '../providers/mqtt_provider.dart';
import '../providers/connectivity_provider.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _brokerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final mqttProvider = context.read<MqttProvider>();
    _topicController.text = mqttProvider.currentTopic;
    _brokerController.text = mqttProvider.broker;
  }

  @override
  void dispose() {
    _topicController.dispose();
    _brokerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('IoT Sensor Data', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        actions: [
          Consumer<MqttProvider>(builder: (context, mqtt, child) {
            return IconButton(
              icon: Icon(mqtt.isConnected ? Icons.cloud_done : Icons.cloud_off, color: mqtt.isConnected ? Colors.green : Colors.red),
              onPressed: () => _showConnectionSettings(context),
            );
          })
        ],
      ),
      body: Consumer2<MqttProvider, ConnectivityProvider>(
        builder: (context, mqtt, connectivity, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConnectionStatusCard(mqtt, connectivity),
                const SizedBox(height: 20),
                _buildCurrentValueCard(mqtt),
                const SizedBox(height: 20),
                _buildTopicCard(mqtt),
                const SizedBox(height: 20),
                _buildPublishCard(mqtt),
                const SizedBox(height: 20),
                _buildHistoryCard(mqtt),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectionStatusCard(MqttProvider mqtt, ConnectivityProvider connectivity) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (!connectivity.isConnected) {
      statusColor = Colors.orange;
      statusText = 'No Internet Connection';
      statusIcon = Icons.wifi_off;
    } else {
      switch (mqtt.connectionState) {
        case MqttConnectionState.connected:
          statusColor = Colors.green;
          statusText = 'Connected to ${mqtt.broker}';
          statusIcon = Icons.cloud_done;
          break;
        case MqttConnectionState.connecting:
          statusColor = Colors.blue;
          statusText = 'Connecting...';
          statusIcon = Icons.cloud_sync;
          break;
        case MqttConnectionState.disconnecting:
          statusColor = Colors.orange;
          statusText = 'Disconnecting...';
          statusIcon = Icons.cloud_off;
          break;
        default:
          statusColor = Colors.red;
          statusText = 'Disconnected';
          statusIcon = Icons.cloud_off;
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: statusColor.withAlpha(26), borderRadius: BorderRadius.circular(12)),
              child: Icon(statusIcon, color: statusColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('MQTT Status', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(statusText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor)),
              ]),
            ),
            ElevatedButton(
              onPressed: connectivity.isConnected ? () => _toggleConnection(context, mqtt) : null,
              style: ElevatedButton.styleFrom(backgroundColor: mqtt.isConnected ? Colors.red : Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: Text(mqtt.isConnected ? 'Disconnect' : 'Connect', style: const TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentValueCard(MqttProvider mqtt) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: [Colors.purple.shade700, Colors.purple.shade400])),
        child: Column(
          children: [
            const Icon(Icons.thermostat, color: Colors.white, size: 28),
            const SizedBox(height: 12),
            Text(mqtt.currentValue, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Topic: ${mqtt.currentTopic}', style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard(MqttProvider mqtt) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Subscribe to Topic', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _topicController, decoration: const InputDecoration(hintText: 'sensor/temperature'))),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () { mqtt.connect(topic: _topicController.text.trim()); }, child: const Text('Subscribe'))
          ])
        ]),
      ),
    );
  }

  Widget _buildPublishCard(MqttProvider mqtt) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Publish Test Message', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: TextEditingController(), decoration: const InputDecoration(hintText: 'value'))),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: mqtt.publishTest, child: const Text('Publish Test'))
          ])
        ]),
      ),
    );
  }

  Widget _buildHistoryCard(MqttProvider mqtt) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...mqtt.sensorHistory.map((s) => ListTile(title: Text(s.value), subtitle: Text('${s.topic} • ${s.timestamp}'))),
        ]),
      ),
    );
  }

  void _toggleConnection(BuildContext context, MqttProvider mqtt) async {
    if (mqtt.isConnected) {
      mqtt.disconnect();
    } else {
      final success = await mqtt.connect(broker: _brokerController.text.trim(), topic: _topicController.text.trim());

      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Connected to MQTT broker' : 'Failed to connect'), backgroundColor: success ? Colors.green : Colors.red));
      }
    }
  }

  void _showConnectionSettings(BuildContext context) {
    final mqtt = context.read<MqttProvider>();
    _brokerController.text = mqtt.broker;

    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Connection Settings'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: _brokerController, decoration: const InputDecoration(labelText: 'Broker Address', hintText: 'broker.hivemq.com')), const SizedBox(height: 16), const Text('Default port: 1883', style: TextStyle(color: Colors.grey, fontSize: 12)),]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]));
  }
}
