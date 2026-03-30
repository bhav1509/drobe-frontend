import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import '../models/outfit.dart';
import '../services/garment_service.dart';
import '../services/outfit_service.dart';
import '../widgets/upload_card.dart';
import '../widgets/outfit_card.dart';
import 'garments_screen.dart';
import 'outfit_journal_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Outfit> outfits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOutfits();
  }

  Future<void> fetchOutfits() async {
    try {
      setState(() {
        isLoading = true;
      });
      final data = await OutfitService.getOutfits(page: 0, size: 10);
      setState(() {
        outfits = data.content;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading outfits: $e')));
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1080,
    );

    if (pickedFile == null) return;

    try {
      await OutfitService.uploadOutfit(File(pickedFile.path));
      await fetchOutfits();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit uploaded successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
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
      await GarmentService.uploadGarment(File(pickedFile.path));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Garment uploaded successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  Future<void> handleProfileMenu(String value) async {
    if (value == 'settings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
      return;
    }

    if (value == 'logout') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout is not wired yet')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DROBE'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: handleProfileMenu,
            icon: const Icon(Icons.account_circle_outlined),
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings'),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Text('Log out'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: UploadCard(
                    title: 'Add Outfit',
                    icon: Icons.image_outlined,
                    onTap: pickAndUploadImage,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: UploadCard(
                    title: 'Add Garment',
                    icon: Icons.checkroom_outlined,
                    onTap: pickAndUploadGarment,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OutfitJournalScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_library_outlined, size: 26),
                        SizedBox(width: 10),
                        Text(
                          'Recent Outfits',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : outfits.isEmpty
                  ? const Center(child: Text('No outfits uploaded yet'))
                  : MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      itemCount: outfits.length,
                      itemBuilder: (context, index) {
                        final outfit = outfits[index];
                        return OutfitCard(outfit: outfit);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade600,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OutfitJournalScreen(),
              ),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GarmentsScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom_outlined),
            label: '',
          ),
        ],
      ),
    );
  }
}
