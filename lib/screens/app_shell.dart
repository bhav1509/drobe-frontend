import 'package:flutter/material.dart';
import 'wardrobe_screen.dart';
import 'home_screen.dart';
import 'outfits_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int currentIndex = 0;
  int homeRefreshToken = 0;

  void _selectTab(int index) {
    if (currentIndex == index) return;

    setState(() {
      currentIndex = index;
      if (index == 0) {
        homeRefreshToken++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomeScreen(
            onTabSelected: _selectTab,
            refreshToken: homeRefreshToken,
          ),
          const OutfitsScreen(),
          const WardrobeScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade600,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _selectTab,
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
