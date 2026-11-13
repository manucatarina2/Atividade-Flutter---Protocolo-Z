class HordeAlert {
  final String id;
  final String authorId;
  final double latitude;
  final double longitude;
  final String intensity;
  final String? description;
  final DateTime createdAt;
  final DateTime expiresAt;

  const HordeAlert({
    required this.id,
    required this.authorId,
    required this.latitude,
    required this.longitude,
    required this.intensity,
    this.description,
    required this.createdAt,
    required this.expiresAt,
  });

  factory HordeAlert.fromJson(Map<String, dynamic> json) => HordeAlert(
        id: json['id'] as String,
        authorId: json['author_id'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        intensity: json['intensity'] as String,
        description: json['description'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        expiresAt: DateTime.parse(json['expires_at'] as String),
      );
}
