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
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
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
            Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
