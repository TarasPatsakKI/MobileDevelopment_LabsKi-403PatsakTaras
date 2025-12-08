import 'package:flutter/material.dart';
import '../widgets/room_card.dart';
import '../widgets/stats_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, bool> roomStates = {
    'Living Room': true,
    'Bedroom': false,
    'Kitchen': true,
    'Bathroom': false,
    'Office': false,
    'Garage': false,
  };

  final Map<String, int> roomLightCounts = {
    'Living Room': 4,
    'Bedroom': 2,
    'Kitchen': 3,
    'Bathroom': 2,
    'Office': 3,
    'Garage': 1,
  };

  int get totalLights => roomLightCounts.values.reduce((a, b) => a + b);
  int get activeLights => roomStates.entries
      .where((e) => e.value)
      .fold(0, (sum, e) => sum + roomLightCounts[e.key]!);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Smart Light Control',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatsCard(activeLights: activeLights, totalLights: totalLights),
            const SizedBox(height: 32),
            const Text(
              'Rooms',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: roomStates.length,
              itemBuilder: (context, index) {
                final room = roomStates.keys.elementAt(index);
                return RoomCard(
                  roomName: room,
                  lightsCount: roomLightCounts[room]!,
                  isOn: roomStates[room]!,
                  onTap: () {
                    setState(() {
                      roomStates[room] = !roomStates[room]!;
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
