class RoomModel {
  final String id;
  final String name;
  final int lightsCount;
  final bool isOn;

  const RoomModel({
    required this.id,
    required this.name,
    required this.lightsCount,
    required this.isOn,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'lightsCount': lightsCount, 'isOn': isOn};
  }

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      lightsCount: json['lightsCount'] as int,
      isOn: json['isOn'] as bool,
    );
  }

  RoomModel copyWith({String? id, String? name, int? lightsCount, bool? isOn}) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lightsCount: lightsCount ?? this.lightsCount,
      isOn: isOn ?? this.isOn,
    );
  }
}
