import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import '../models/garment.dart';
import '../services/garment_service.dart';
import '../widgets/garment_card.dart';

class GarmentsScreen extends StatefulWidget {
  const GarmentsScreen({super.key});

  @override
  State<GarmentsScreen> createState() => _GarmentsScreenState();
}

class _GarmentsScreenState extends State<GarmentsScreen> {
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
      if (!mounted) return;
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GARMENTS'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: isUploading ? null : pickAndUploadGarment,
            icon: isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
            tooltip: 'Add garment',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                  return GarmentCard(garment: garment);
                },
              ),
      ),
    );
  }
}
