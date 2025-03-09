import 'package:uuid/uuid.dart';

class Player {
  final String id;

  final String name;

  final int weight;

  Player({String? id, required this.name, required this.weight})
      : id = id ?? const Uuid().v7();

  Player copyWith({String? id, String? name, int? weight}) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'weight': weight};
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(id: json['id'], name: json['name'], weight: json['weight']);
  }
}
