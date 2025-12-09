import '../../data/models/room_model.dart';
import '../../data/repositories/room_repository.dart';

class RoomService {
  final RoomRepository _roomRepository;

  RoomService(this._roomRepository);

  Future<List<RoomModel>> getAllRooms() async {
    return await _roomRepository.getAllRooms();
  }

  Future<RoomModel?> getRoomById(String id) async {
    return await _roomRepository.getRoomById(id);
  }

  Future<bool> addRoom({required String name, required int lightsCount}) async {
    final room = RoomModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      lightsCount: lightsCount,
      isOn: false,
    );

    return await _roomRepository.addRoom(room);
  }

  Future<bool> updateRoom(RoomModel room) async {
    return await _roomRepository.updateRoom(room);
  }

  Future<bool> deleteRoom(String id) async {
    return await _roomRepository.deleteRoom(id);
  }

  Future<bool> toggleRoom(String id) async {
    return await _roomRepository.toggleRoomState(id);
  }

  int getTotalLights(List<RoomModel> rooms) {
    return rooms.fold(0, (sum, room) => sum + room.lightsCount);
  }

  int getActiveLights(List<RoomModel> rooms) {
    return rooms
        .where((room) => room.isOn)
        .fold(0, (sum, room) => sum + room.lightsCount);
  }
}
