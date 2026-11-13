class ExpeditionType {
  final String id;
  final String name;
  final String description;
  final int durationSeconds;
  final String risk;

  const ExpeditionType({
    required this.id,
    required this.name,
    required this.description,
    required this.durationSeconds,
    required this.risk,
  });

  factory ExpeditionType.fromJson(Map<String, dynamic> json) => ExpeditionType(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        durationSeconds: json['duration_seconds'] as int,
        risk: json['risk'] as String,
      );
}
