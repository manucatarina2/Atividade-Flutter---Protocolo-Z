class Faction {
  final String id;
  final String name;
  final String symbol;
  final String color;
  final String? description;

  const Faction({
    required this.id,
    required this.name,
    required this.symbol,
    required this.color,
    this.description,
  });

  factory Faction.fromJson(Map<String, dynamic> json) => Faction(
        id: json['id'] as String,
        name: json['name'] as String,
        symbol: json['symbol'] as String,
        color: json['color'] as String,
        description: json['description'] as String?,
      );
}
