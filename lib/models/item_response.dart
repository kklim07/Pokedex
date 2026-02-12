import 'item.dart';

class ItemResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Item> results;

  ItemResponse({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory ItemResponse.fromJson(Map<String, dynamic> json) {
    return ItemResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List)
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
