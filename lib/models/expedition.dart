import 'expedition_type.dart';

class Expedition {
  final String id;
  final String playerId;
  final String expeditionTypeId;
  final DateTime startedAt;
  final DateTime endsAt;
  final String status;
  final ExpeditionType? type;

  const Expedition({
    required this.id,
    required this.playerId,
    required this.expeditionTypeId,
    required this.startedAt,
    required this.endsAt,
    required this.status,
    this.type,
  });

  bool get isRunning =>
      status == 'em_andamento' && DateTime.now().isBefore(endsAt);
  bool get isReady =>
      status == 'em_andamento' && DateTime.now().isAfter(endsAt);

  factory Expedition.fromJson(Map<String, dynamic> json) => Expedition(
        id: json['id'] as String,
        playerId: json['player_id'] as String,
        expeditionTypeId: json['expedition_type_id'] as String,
        startedAt: DateTime.parse(json['started_at'] as String).toLocal(),
        endsAt: DateTime.parse(json['ends_at'] as String).toLocal(),
        status: json['status'] as String,
        type: json['expedition_types'] != null
            ? ExpeditionType.fromJson(
                json['expedition_types'] as Map<String, dynamic>)
            : null,
      );
}
