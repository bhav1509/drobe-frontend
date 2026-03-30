class Outfit {
  final int id;
  final String createdAt;
  final String imageUrl;

  Outfit({
    required this.id,
    required this.createdAt,
    required this.imageUrl,
  });

  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      id: json['id'],
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
    );
  }
}