import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/outfit.dart';

class OutfitCard extends StatelessWidget {
  final Outfit outfit;

  const OutfitCard({
    super.key,
    required this.outfit,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = outfit.imageUrl;

    DateTime? date;
    String formattedDate = '';

    try {
      date = DateTime.parse(outfit.createdAt).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      formattedDate = 'Unknown date';
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.fitWidth,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 40),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
