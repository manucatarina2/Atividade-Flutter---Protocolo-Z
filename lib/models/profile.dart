import 'faction.dart';

class Profile {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final String? factionId;
  final int reputation;
  final Faction? faction;

  const Profile({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    this.factionId,
    required this.reputation,
    this.faction,
  });

  bool get hasFaction => factionId != null;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        nickname: json['nickname'] as String,
        avatarUrl: json['avatar_url'] as String?,
        factionId: json['faction_id'] as String?,
        reputation: (json['reputation'] as int?) ?? 0,
        faction: json['factions'] != null
            ? Faction.fromJson(json['factions'] as Map<String, dynamic>)
            : null,
      );
}
