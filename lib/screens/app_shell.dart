import 'package:flutter/material.dart';
import '../app_state.dart';
import 'wardrobe_screen.dart';
import 'home_screen.dart';
import 'outfits_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  ContentTab? _selectedTab;
  int homeRefreshToken = 0;
  bool _initialized = false;

  void _selectTab(ContentTab tab) {
    if (_selectedTab == tab) return;

    setState(() {
      _selectedTab = tab;
      if (tab == ContentTab.suggestions) {
        homeRefreshToken++;
      }
    });
  }

  Widget _buildScreenFor(ContentTab tab) {
    switch (tab) {
      case ContentTab.suggestions:
        return HomeScreen(
          onTabSelected: (index) {
            final visibleTabs = AppStateScope.of(context).visibleTabs;
            if (index >= 0 && index < visibleTabs.length) {
              _selectTab(visibleTabs[index]);
            }
          },
          refreshToken: homeRefreshToken,
        );
      case ContentTab.outfits:
        return const OutfitsScreen();
      case ContentTab.wardrobe:
        return const WardrobeScreen();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _selectedTab = AppStateScope.of(context).defaultTab;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final visibleTabs = appState.visibleTabs;
    final selectedTab = visibleTabs.contains(_selectedTab)
        ? _selectedTab!
        : visibleTabs.first;
    final effectiveIndex = visibleTabs.indexOf(selectedTab);

    return Scaffold(
      body: IndexedStack(
        index: effectiveIndex,
        children: visibleTabs
            .map(
              (tab) => HeroMode(
                enabled: tab == selectedTab,
                child: _buildScreenFor(tab),
              ),
            )
            .toList(),
      ),
      bottomNavigationBar: visibleTabs.length < 2
          ? null
          : BottomNavigationBar(
              currentIndex: effectiveIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedItemColor: Theme.of(context).colorScheme.onSurface,
              unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              onTap: (index) => _selectTab(visibleTabs[index]),
              items: visibleTabs
                  .map(
                    (tab) => BottomNavigationBarItem(
                      icon: Icon(tab.icon),
                      label: tab.label,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
