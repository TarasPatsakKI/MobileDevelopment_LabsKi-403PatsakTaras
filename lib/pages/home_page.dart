import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/room_card.dart';
import '../widgets/stats_card.dart';
import '../domain/services/room_service.dart';
import '../domain/services/auth_service.dart';
import '../data/repositories/room_repository_impl.dart';
import '../data/repositories/user_repository_impl.dart';
import '../data/models/room_model.dart';
import '../providers/connectivity_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final RoomService _roomService;
  late final AuthService _authService;

  List<RoomModel> _rooms = [];
  bool _isLoading = true;
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _roomService = RoomService(RoomRepositoryImpl());
    _authService = AuthService(UserRepositoryImpl());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final user = await _authService.getCurrentUser();
    if (user != null) {
      _userEmail = user.email;
    }

    final rooms = await _roomService.getAllRooms();

    setState(() {
      _rooms = rooms;
      _isLoading = false;
    });
  }

  Future<void> _toggleRoom(String id) async {
    final success = await _roomService.toggleRoom(id);
    if (success) {
      await _loadData();
    }
  }

  Future<void> _showAddRoomDialog() async {
    final nameController = TextEditingController();
    final lightsController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Room Name',
                hintText: 'e.g., Living Room',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lightsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of Lights',
                hintText: 'e.g., 3',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  lightsController.text.isNotEmpty) {
                final success = await _roomService.addRoom(
                  name: nameController.text,
                  lightsCount: int.tryParse(lightsController.text) ?? 1,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    await _loadData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Room added successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditRoomDialog(RoomModel room) async {
    final nameController = TextEditingController(text: room.name);
    final lightsController = TextEditingController(
      text: room.lightsCount.toString(),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Room Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lightsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Number of Lights'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  lightsController.text.isNotEmpty) {
                final updatedRoom = room.copyWith(
                  name: nameController.text,
                  lightsCount:
                      int.tryParse(lightsController.text) ?? room.lightsCount,
                );

                final success = await _roomService.updateRoom(updatedRoom);

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    await _loadData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Room updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRoom(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room'),
        content: const Text('Are you sure you want to delete this room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _roomService.deleteRoom(id);
      if (success) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Room deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalLights = _roomService.getTotalLights(_rooms);
    final activeLights = _roomService.getActiveLights(_rooms);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Smart Light Control',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (_userEmail.isNotEmpty)
              Text(
                _userEmail,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sensors, color: Colors.black),
            tooltip: 'IoT Sensors',
            onPressed: () {
              Navigator.pushNamed(context, '/sensors');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () async {
              await Navigator.pushNamed(context, '/profile');
              _loadData();
            },
          ),
        ],
      ),
      body: Consumer<ConnectivityProvider>(
        builder: (context, connectivity, child) {
          return Column(
            children: [
              // Offline banner
              if (!connectivity.isConnected)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  color: Colors.orange,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'No Internet Connection - Limited functionality',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StatsCard(
                                activeLights: activeLights,
                                totalLights: totalLights,
                              ),
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Rooms',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle, size: 32),
                                    color: Theme.of(context).colorScheme.primary,
                                    onPressed: _showAddRoomDialog,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _rooms.isEmpty
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(40),
                                        child: Text(
                                          'No rooms yet. Add one to get started!',
                                        ),
                                      ),
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                            childAspectRatio: 1,
                                          ),
                                      itemCount: _rooms.length,
                                      itemBuilder: (context, index) {
                                        final room = _rooms[index];
                                        return RoomCard(
                                          roomName: room.name,
                                          lightsCount: room.lightsCount,
                                          isOn: room.isOn,
                                          onTap: () => _toggleRoom(room.id),
                                          onEdit: () => _showEditRoomDialog(room),
                                          onDelete: () => _deleteRoom(room.id),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
