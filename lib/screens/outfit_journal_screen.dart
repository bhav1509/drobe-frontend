import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/outfit.dart';
import '../services/outfit_service.dart';
import '../widgets/journal_outfit_item.dart';

class OutfitJournalScreen extends StatefulWidget {
  const OutfitJournalScreen({super.key});

  @override
  State<OutfitJournalScreen> createState() => _OutfitJournalScreenState();
}

class _OutfitJournalScreenState extends State<OutfitJournalScreen> {
  final ScrollController _scrollController = ScrollController();

  List<Outfit> outfits = [];
  int currentPage = 0;
  bool isLoading = false;
  bool isUploading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    fetchNextPage();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !isLoading &&
          hasMore) {
        fetchNextPage();
      }
    });
  }

  Future<void> fetchNextPage() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await OutfitService.getOutfits(
        page: currentPage,
        size: 10,
      );

      setState(() {
        outfits.addAll(response.content);
        currentPage++;
        hasMore = !response.last;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading journal: $e')),
      );
    }
  }

  Future<void> refreshOutfits() async {
    setState(() {
      outfits = [];
      currentPage = 0;
      hasMore = true;
    });

    await fetchNextPage();
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
      setState(() {
        isUploading = true;
      });

      await OutfitService.uploadOutfit(File(pickedFile.path));
      await refreshOutfits();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit uploaded successfully')),
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

  Map<String, List<Outfit>> groupOutfitsByYear(List<Outfit> outfits) {
    final Map<String, List<Outfit>> grouped = {};

    for (final outfit in outfits) {
      String key = 'Unknown';

      try {
        final date = DateTime.parse(outfit.createdAt).toLocal();
        key = DateFormat('yyyy').format(date);
      } catch (_) {}

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(outfit);
    }

    return grouped;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupOutfitsByYear(outfits);
    final sectionTitles = grouped.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Journal'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: isUploading ? null : pickAndUploadImage,
            icon: isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
            tooltip: 'Add outfit',
          ),
        ],
      ),
      body: outfits.isEmpty && isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...sectionTitles.map((sectionTitle) {
                    final sectionOutfits = grouped[sectionTitle]!;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sectionTitle,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sectionOutfits.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 255,
                            ),
                            itemBuilder: (context, index) {
                              final outfit = sectionOutfits[index];

                              return JournalOutfitItem(
                                outfit: outfit,
                                onDeleted: () {
                                  setState(() {
                                    outfits.removeWhere(
                                      (item) => item.id == outfit.id,
                                    );
                                  });
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
    );
  }
}
