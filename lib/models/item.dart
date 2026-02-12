class Item {
  final int id;
  final String name;
  final String url;
  final String imageUrl;

  Item({
    required this.id,
    required this.name,
    required this.url,
    required this.imageUrl,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    final id = int.parse(url.split('/').where((e) => e.isNotEmpty).last);

    return Item(
      id: id,
      name: json['name'] as String,
      url: url,
      imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/${json['name'] as String}.png',
    );
  }
}
