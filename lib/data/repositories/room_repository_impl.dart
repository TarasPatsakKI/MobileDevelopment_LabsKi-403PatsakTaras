import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api_client.dart';
import '../models/room_model.dart';
import 'room_repository.dart';

class RoomRepositoryImpl implements RoomRepository {
  final ApiClient? apiClient;
  static const _cacheKey = 'rooms_cache';

  RoomRepositoryImpl({this.apiClient});

  @override
  Future<bool> addRoom(RoomModel room) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rooms = await getAllRooms();
      final newList = List<RoomModel>.from(rooms)..add(room);
      await prefs.setString(_cacheKey, jsonEncode(newList.map((r) => r.toJson()).toList()));

      if (apiClient != null) {
        await apiClient!.post('/rooms', data: room.toJson());
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteRoom(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rooms = await getAllRooms();
      final newList = rooms.where((r) => r.id != id).toList();
      await prefs.setString(_cacheKey, jsonEncode(newList.map((r) => r.toJson()).toList()));

      if (apiClient != null) {
        await apiClient!.post('/rooms/delete', data: {'id': id});
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<RoomModel?> getRoomById(String id) async {
    final rooms = await getAllRooms();
    try {
      return rooms.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<RoomModel>> getAllRooms() async {
    try {
      if (apiClient != null) {
        final resp = await apiClient!.get('/rooms');
        if (resp.statusCode == 200 && resp.data != null) {
          final data = resp.data is List ? resp.data : (resp.data['rooms'] ?? resp.data['data'] ?? []);
          final list = List<Map<String, dynamic>>.from(data as List);
          final rooms = list.map((j) => RoomModel.fromJson(j)).toList();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cacheKey, jsonEncode(rooms.map((r) => r.toJson()).toList()));
          return rooms;
        }
      }
    } catch (_) {
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached == null) return [];
      final list = List<Map<String, dynamic>>.from(jsonDecode(cached) as List);
      return list.map((j) => RoomModel.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> toggleRoomState(String id) async {
    try {
      final rooms = await getAllRooms();
      final idx = rooms.indexWhere((r) => r.id == id);
      if (idx == -1) return false;
      final updated = rooms[idx].copyWith(isOn: !rooms[idx].isOn);
      rooms[idx] = updated;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(rooms.map((r) => r.toJson()).toList()));

      if (apiClient != null) {
        await apiClient!.post('/rooms/toggle', data: {'id': id});
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> updateRoom(RoomModel room) async {
    try {
      final rooms = await getAllRooms();
      final idx = rooms.indexWhere((r) => r.id == room.id);
      if (idx == -1) return false;
      rooms[idx] = room;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(rooms.map((r) => r.toJson()).toList()));

      if (apiClient != null) {
        await apiClient!.post('/rooms/update', data: room.toJson());
      }

      return true;
    } catch (_) {
      return false;
    }
  }
}

