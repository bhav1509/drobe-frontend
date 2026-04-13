import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/garment.dart';
import '../screens/wardrobe_detail_screen.dart';

class GarmentCard extends StatelessWidget {
  final Garment garment;
  final VoidCallback? onDeleted;

  const GarmentCard({
    super.key,
    required this.garment,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    String formattedDate = '';

    try {
      final date = DateTime.parse(garment.createdAt).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      formattedDate = 'Unknown date';
    }

    return GestureDetector(
      onTap: () async {
        final wasDeleted = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => WardrobeDetailScreen(garment: garment),
          ),
        );

        if (wasDeleted == true) {
          onDeleted?.call();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.network(
                    garment.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: scheme.surfaceContainer,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 40),
                        ),
                      );
                    },
                  ),
                  Container(
                    color: scheme.surfaceContainerHighest,
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
          ),
        ],
      ),
    );
  }
}
