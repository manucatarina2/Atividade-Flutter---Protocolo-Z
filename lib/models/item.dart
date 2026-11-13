class Item {
  final String id;
  final String name;
  final String category;
  final String? icon;

  const Item({
    required this.id,
    required this.name,
    required this.category,
    this.icon,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        icon: json['icon'] as String?,
      );
}
