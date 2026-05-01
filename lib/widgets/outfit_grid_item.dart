import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/outfit.dart';
import '../screens/outfit_detail_screen.dart';
import '../services/auth_service.dart';

class OutfitGridItem extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback? onDeleted;

  const OutfitGridItem({super.key, required this.outfit, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    String formattedDate = 'Unknown date';

    try {
      final date = DateTime.parse(outfit.createdAt).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(date);
    } catch (_) {}

    return GestureDetector(
      onTap: () async {
        final wasDeleted = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => OutfitDetailScreen(outfit: outfit),
          ),
        );

        if (wasDeleted == true) {
          onDeleted?.call();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                outfit.imageUrl,
                headers: AuthService.authorizationHeaders,
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
    );
  }
}
