import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/garment.dart';

class GarmentCard extends StatelessWidget {
  final Garment garment;

  const GarmentCard({
    super.key,
    required this.garment,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = '';

    try {
      final date = DateTime.parse(garment.createdAt).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      formattedDate = 'Unknown date';
    }

    return Column(
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
            garment.imageUrl,
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
    );
  }
}
