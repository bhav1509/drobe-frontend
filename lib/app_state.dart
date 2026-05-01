import 'package:flutter/material.dart';
import 'services/auth_service.dart';

enum ThemePreference { system, light, dark }

enum AccountStatus { signedOut, guest, signedIn }

enum ContentTab { suggestions, outfits, wardrobe }

extension ContentTabView on ContentTab {
  String get label {
    switch (this) {
      case ContentTab.suggestions:
        return 'Suggestions';
      case ContentTab.outfits:
        return 'Outfits';
      case ContentTab.wardrobe:
        return 'Wardrobe';
    }
  }

  IconData get icon {
    switch (this) {
      case ContentTab.suggestions:
        return Icons.auto_awesome;
      case ContentTab.outfits:
        return Icons.photo_library_outlined;
      case ContentTab.wardrobe:
        return Icons.checkroom_outlined;
    }
  }
}

class AppState extends ChangeNotifier {
  ThemePreference _themePreference = ThemePreference.system;
  AccountStatus _accountStatus = AccountStatus.signedOut;
  String _accountLabel = 'Signed out';
  final Map<ContentTab, bool> _visibleTabs = {
    ContentTab.suggestions: true,
    ContentTab.outfits: true,
    ContentTab.wardrobe: true,
  };
  ContentTab _defaultTab = ContentTab.suggestions;

  ThemePreference get themePreference => _themePreference;
  AccountStatus get accountStatus => _accountStatus;
  String get accountLabel => _accountLabel;
  ContentTab get defaultTab => _defaultTab;

  ThemeMode get themeMode {
    switch (_themePreference) {
      case ThemePreference.system:
        return ThemeMode.system;
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
    }
  }

  List<ContentTab> get visibleTabs {
    return ContentTab.values.where((tab) => _visibleTabs[tab] == true).toList();
  }

  bool isTabVisible(ContentTab tab) => _visibleTabs[tab] == true;

  void setThemePreference(ThemePreference preference) {
    if (_themePreference == preference) return;
    _themePreference = preference;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    final session = await AuthService.signInWithGoogle();
    _accountStatus = AccountStatus.signedIn;
    _accountLabel = session.label;
    notifyListeners();
  }

  void useGuest() {
    _accountStatus = AccountStatus.guest;
    _accountLabel = 'Guest session';
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.logout();
    _accountStatus = AccountStatus.signedOut;
    _accountLabel = 'Signed out';
    notifyListeners();
  }

  void setTabVisibility(ContentTab tab, bool visible) {
    if (!visible && visibleTabs.length == 1 && isTabVisible(tab)) {
      return;
    }

    _visibleTabs[tab] = visible;

    if (!isTabVisible(_defaultTab)) {
      _defaultTab = visibleTabs.firstWhere(
        (item) => item != tab || visible,
        orElse: () => ContentTab.suggestions,
      );
    }

    notifyListeners();
  }

  void setDefaultTab(ContentTab tab) {
    if (!isTabVisible(tab)) return;
    if (_defaultTab == tab) return;
    _defaultTab = tab;
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in widget tree');
    return scope!.notifier!;
  }
}
