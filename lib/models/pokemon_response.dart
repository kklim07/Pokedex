import 'pokemon.dart';

class PokemonResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Pokemon> results;

  PokemonResponse({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory PokemonResponse.fromJson(Map<String, dynamic> json) {
    return PokemonResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List)
          .map((e) => Pokemon.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
