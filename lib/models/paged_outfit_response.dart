import 'outfit.dart';

class PagedOutfitResponse {
  final List<Outfit> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final bool last;

  PagedOutfitResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.last,
  });

  factory PagedOutfitResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> items = json['content'] ?? [];

    return PagedOutfitResponse(
      content: items.map((item) => Outfit.fromJson(item)).toList(),
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      number: json['number'] ?? 0,
      last: json['last'] ?? true,
    );
  }
}
