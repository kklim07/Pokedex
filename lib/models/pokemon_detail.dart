class PokemonDetail {
  final int id;
  final String name;
  final String shinyName;
  final int height;
  final int weight;
  final List<String> types;
  final List<String> abilities;
  final Map<String, int> stats;
  final String imageUrl;
  final String imageUrlShiny;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.shinyName,
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    required this.stats,
    required this.imageUrl,
    required this.imageUrlShiny,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final types = (json['types'] as List)
        .map((e) => e['type']['name'] as String)
        .toList();

    final abilities = (json['abilities'] as List)
        .map((e) => e['ability']['name'] as String)
        .toList();

    final stats = <String, int>{};
    for (var stat in json['stats'] as List) {
      final statName = stat['stat']['name'] as String;
      final baseStat = stat['base_stat'] as int;
      stats[statName] = baseStat;
    }

    final id = json['id'] as int;

    String? imageUrl;
    imageUrl ??= (json['sprites']?['front_default'] as String?);
    imageUrl ??='https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

    String? imageUrlShiny;
    imageUrlShiny ??= (json['sprites']?['front_shiny'] as String?);
    imageUrlShiny ??='https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/$id.png';

    String pokemonName = (json['name'] as String?) ?? '';

    String nameRaw = json['name'] as String? ?? 'Unknown';
    String pokemonShinyName = "Shiny $nameRaw";

    return PokemonDetail(
      id: id,
      name: pokemonName,
      shinyName: pokemonShinyName,
      height: json['height'] as int? ?? 0,
      weight: json['weight'] as int? ?? 0,
      types: types,
      abilities: abilities,
      stats: stats,
      imageUrl: imageUrl,
      imageUrlShiny: imageUrlShiny,
    );
  }

  String get heightInMeters => (height / 10).toStringAsFixed(1);
  String get weightInKg => (weight / 10).toStringAsFixed(1);
}
