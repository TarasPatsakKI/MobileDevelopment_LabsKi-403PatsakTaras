import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/room_model.dart';
import '../repositories/room_repository.dart';

class RoomRepositoryImpl implements RoomRepository {
  static const String _roomsKey = 'rooms';

  @override
  Future<List<RoomModel>> getAllRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roomsJson = prefs.getString(_roomsKey);

      if (roomsJson == null) {
        return _getDefaultRooms();
      }

      final List<Map<String, dynamic>> roomsList =
          List<Map<String, dynamic>>.from(jsonDecode(roomsJson) as List);

      return roomsList.map((json) => RoomModel.fromJson(json)).toList();
    } catch (e) {
      return _getDefaultRooms();
    }
  }

  @override
  Future<RoomModel?> getRoomById(String id) async {
    try {
      final rooms = await getAllRooms();
      return rooms.firstWhere(
        (room) => room.id == id,
        orElse: () => throw Exception('Room not found'),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> addRoom(RoomModel room) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rooms = await getAllRooms();

      rooms.add(room);

      final roomsJson = rooms.map((r) => r.toJson()).toList();
      await prefs.setString(_roomsKey, jsonEncode(roomsJson));

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateRoom(RoomModel room) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rooms = await getAllRooms();

      final index = rooms.indexWhere((r) => r.id == room.id);

      if (index == -1) {
        return false;
      }

      rooms[index] = room;

      final roomsJson = rooms.map((r) => r.toJson()).toList();
      await prefs.setString(_roomsKey, jsonEncode(roomsJson));

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteRoom(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rooms = await getAllRooms();

      rooms.removeWhere((r) => r.id == id);

      final roomsJson = rooms.map((r) => r.toJson()).toList();
      await prefs.setString(_roomsKey, jsonEncode(roomsJson));

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> toggleRoomState(String id) async {
    try {
      final room = await getRoomById(id);

      if (room == null) {
        return false;
      }

      final updatedRoom = room.copyWith(isOn: !room.isOn);
      return await updateRoom(updatedRoom);
    } catch (e) {
      return false;
    }
  }

  List<RoomModel> _getDefaultRooms() {
    return [
      const RoomModel(id: '1', name: 'Living Room', lightsCount: 4, isOn: true),
      const RoomModel(id: '2', name: 'Bedroom', lightsCount: 2, isOn: false),
      const RoomModel(id: '3', name: 'Kitchen', lightsCount: 3, isOn: true),
      const RoomModel(id: '4', name: 'Bathroom', lightsCount: 2, isOn: false),
      const RoomModel(id: '5', name: 'Office', lightsCount: 3, isOn: false),
      const RoomModel(id: '6', name: 'Garage', lightsCount: 1, isOn: false),
    ];
  }
}
