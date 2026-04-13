import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import '../models/garment.dart';
import '../services/garment_service.dart';
import '../widgets/garment_card.dart';
import '../widgets/profile_menu_button.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  List<Garment> garments = [];
  bool isLoading = true;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    fetchGarments();
  }

  Future<void> fetchGarments() async {
    try {
      setState(() {
        isLoading = true;
      });

      final data = await GarmentService.getGarments(page: 0, size: 10);

      setState(() {
        garments = data.content;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading garments: $e')));
    }
  }

  Future<void> pickAndUploadGarment() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1080,
    );

    if (pickedFile == null) return;

    try {
      setState(() {
        isUploading = true;
      });

      await GarmentService.uploadGarment(File(pickedFile.path));
      await fetchGarments();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Garment uploaded successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WARDROBE'),
        actions: [
          const ProfileMenuButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.checkroom_outlined, size: 24),
                SizedBox(width: 10),
                Text(
                  'Wardrobe',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : garments.isEmpty
                  ? const Center(child: Text('No garments uploaded yet'))
                  : MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      itemCount: garments.length,
                      itemBuilder: (context, index) {
                        final garment = garments[index];
                        return GarmentCard(
                          garment: garment,
                          onDeleted: () {
                            setState(() {
                              garments.removeWhere(
                                (item) => item.id == garment.id,
                              );
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'wardrobe-upload-fab',
        onPressed: isUploading ? null : pickAndUploadGarment,
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
        shape: const CircleBorder(),
        child: isUploading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.add),
      ),
    );
  }
}
