import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/garment.dart';
import '../services/garment_service.dart';

class WardrobeDetailScreen extends StatefulWidget {
  final Garment garment;

  const WardrobeDetailScreen({super.key, required this.garment});

  @override
  State<WardrobeDetailScreen> createState() => _WardrobeDetailScreenState();
}

class _WardrobeDetailScreenState extends State<WardrobeDetailScreen> {
  bool isDeleting = false;

  Future<void> _deleteGarment() async {
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
      await GarmentService.deleteGarment(widget.garment.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Garment deleted')),
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
      final date = DateTime.parse(widget.garment.createdAt).toLocal();
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
            onPressed: isDeleting ? null : _deleteGarment,
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
            tooltip: 'Delete garment',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4.0,
          child: Image.network(
            widget.garment.imageUrl,
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
