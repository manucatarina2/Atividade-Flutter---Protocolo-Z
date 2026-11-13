import 'profile.dart';

class Shelter {
  final String id;
  final String authorId;
  final String name;
  final String? description;
  final int? capacity;
  final String? photoUrl;
  final double latitude;
  final double longitude;
  final String visibility;
  final String status;
  final Profile? author;

  // ADICIONE ESTES DOIS GETTERS AQUI:
  bool get isPublic => visibility == 'public';
  bool get isSafe => status == 'safe';

  const Shelter({
    required this.id,
    required this.authorId,
    required this.name,
    this.description,
    this.capacity,
    this.photoUrl,
    required this.latitude,
    required this.longitude,
    required this.visibility,
    required this.status,
    this.author,
  });

  factory Shelter.fromJson(Map<String, dynamic> json) => Shelter(
        id: json['id'] as String,
        authorId: json['author_id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        capacity: json['capacity'] as int?,
        photoUrl: json['photo_url'] as String?,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        visibility: json['visibility'] as String,
        status: json['status'] as String,
        author: json['profiles'] != null
            ? Profile.fromJson(json['profiles'] as Map<String, dynamic>)
            : null,
      );
}
