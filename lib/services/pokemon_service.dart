import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_response.dart';
import '../models/pokemon_detail.dart';
import '../models/item_response.dart';
import '../models/item_detail.dart';

class PokemonService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  static const int _pageSize = 20;

  Future<PokemonResponse> getPokemon({
    int limit = _pageSize,
    int offset = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/pokemon?limit=$limit&offset=$offset'),
      );

      if (response.statusCode == 200) {
        return PokemonResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw Exception('Failed to load pokemon');
      }
    } catch (e) {
      throw Exception('Failed to load pokemon: $e');
    }
  }

  Future<PokemonDetail> getPokemonDetail(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return PokemonDetail.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw Exception('Failed to load pokemon details');
      }
    } catch (e) {
      throw Exception('Failed to load pokemon details: $e');
    }
  }

  Future<PokemonDetail> getPokemonDetailByName(String nameOrId) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/pokemon/${nameOrId.toLowerCase()}'));

      if (response.statusCode == 200) {
        return PokemonDetail.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw Exception('Failed to load pokemon details');
      }
    } catch (e) {
      throw Exception('Failed to load pokemon details: $e');
    }
  }

  Future<ItemResponse> getItems({
    int limit = _pageSize,
    int offset = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/item?limit=$limit&offset=$offset'),
      );

      if (response.statusCode == 200) {
        return ItemResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      throw Exception('Failed to load items: $e');
    }
  }

  Future<ItemDetail> getItemDetail(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return ItemDetail.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw Exception('Failed to load item details');
      }
    } catch (e) {
      throw Exception('Failed to load item details: $e');
    }
  }
}
