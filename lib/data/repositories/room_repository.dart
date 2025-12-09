import '../models/room_model.dart';

abstract class RoomRepository {
  Future<List<RoomModel>> getAllRooms();
  Future<RoomModel?> getRoomById(String id);
  Future<bool> addRoom(RoomModel room);
  Future<bool> updateRoom(RoomModel room);
  Future<bool> deleteRoom(String id);
  Future<bool> toggleRoomState(String id);
}
