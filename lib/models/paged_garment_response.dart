import 'garment.dart';

class PagedGarmentResponse {
  final List<Garment> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final bool last;

  PagedGarmentResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.last,
  });

  factory PagedGarmentResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> items = json['content'] ?? [];

    return PagedGarmentResponse(
      content: items.map((item) => Garment.fromJson(item)).toList(),
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      number: json['number'] ?? 0,
      last: json['last'] ?? true,
    );
  }
}
