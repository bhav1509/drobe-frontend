import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/outfit.dart';
import '../services/outfit_service.dart';

class OutfitDetailScreen extends StatefulWidget {
  final Outfit outfit;

  const OutfitDetailScreen({super.key, required this.outfit});

  @override
  State<OutfitDetailScreen> createState() => _OutfitDetailScreenState();
}

class _OutfitDetailScreenState extends State<OutfitDetailScreen> {
  bool isDeleting = false;

  Future<void> _deleteOutfit() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete photo?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() {
      isDeleting = true;
    });

    try {
      await OutfitService.deleteOutfit(widget.outfit.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo deleted')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isDeleting = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    String formattedDate = 'Unknown date';

    try {
      final date = DateTime.parse(widget.outfit.createdAt).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(date);
    } catch (_) {}

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        iconTheme: IconThemeData(color: scheme.onSurface),
        title: Text(
          formattedDate,
          style: TextStyle(color: scheme.onSurface),
        ),
        actions: [
          IconButton(
            onPressed: isDeleting ? null : _deleteOutfit,
            icon: isDeleting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(scheme.onSurface),
                    ),
                  )
                : const Icon(Icons.delete_outline),
            tooltip: 'Delete photo',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4.0,
          child: Image.network(
            widget.outfit.imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(Icons.broken_image, color: scheme.onSurface, size: 48),
              );
            },
          ),
        ),
      ),
    );
  }
}
