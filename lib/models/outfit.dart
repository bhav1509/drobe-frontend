class Outfit {
  final int id;
  final String createdAt;
  final String imageUrl;

  Outfit({required this.id, required this.createdAt, required this.imageUrl});

  factory Outfit.fromJson(Map<String, dynamic> json) {
    final media = json['media'] as Map<String, dynamic>? ?? {};

    return Outfit(
      id: json['id'],
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
      imageUrl:
          json['image_url'] ??
          json['imageUrl'] ??
          media['processedUrl'] ??
          media['originalUrl'] ??
          '',
    );
  }
}
