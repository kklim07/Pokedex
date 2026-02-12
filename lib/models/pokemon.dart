class Pokemon {
  final String name;
  final String url;
  final int id;
  final String imageUrl;

  Pokemon({
    required this.name,
    required this.url,
    required this.id,
    required this.imageUrl,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    final id = int.parse(url.split('/').where((e) => e.isNotEmpty).last);
    
    return Pokemon(
      name: json['name'] as String,
      url: url,
      id: id,
      imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png'
    );
  }
}
