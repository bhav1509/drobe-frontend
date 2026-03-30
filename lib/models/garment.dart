class Garment {
  final int id;
  final String createdAt;
  final String imageUrl;

  Garment({
    required this.id,
    required this.createdAt,
    required this.imageUrl,
  });

  factory Garment.fromJson(Map<String, dynamic> json) {
    return Garment(
      id: json['id'],
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
    );
  }
}
