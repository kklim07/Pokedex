class ItemDetail {
  final int id;
  final String name;
  final String? description;
  final int? cost;
  final String? category;
  final List<String> attributes;
  final String imageUrl;

  ItemDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.category,
    required this.attributes,
    required this.imageUrl,
  });

  factory ItemDetail.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;

    String? description;
    try {
      final flavorText = json['flavor_text_entries'] as List?;
      if (flavorText != null && flavorText.isNotEmpty) {
        final rawText = flavorText[0]['text'] as String? ?? '';
        description = rawText.replaceAll(RegExp(r'\s+'), ' ').trim();
      }
    } catch (_) {
      description = null;
    }

    final attributes = <String>[];
    try {
      final attrs = json['attributes'] as List?;
      if (attrs != null) {
        attributes.addAll(attrs.map((a) => a['name'] as String));
      }
    } catch (_) {}

    return ItemDetail(
      id: json['id'] as int,
      name: name,
      description: description,
      cost: json['cost'] as int?,
      category: json['category']?['name'] as String?,
      attributes: attributes,
      imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/$name.png",
    );
  }
}