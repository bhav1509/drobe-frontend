import 'package:flutter/material.dart';
import 'app_state.dart';
import 'screens/app_shell.dart';

void main() {
  runApp(const DrobeApp());
}

class DrobeApp extends StatefulWidget {
  const DrobeApp({super.key});

  @override
  State<DrobeApp> createState() => _DrobeAppState();
}

class _DrobeAppState extends State<DrobeApp> {
  final AppState _appState = AppState();

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF202020),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: AnimatedBuilder(
        animation: _appState,
        builder: (context, _) {
          return MaterialApp(
            title: 'DROBE',
            debugShowCheckedModeBanner: false,
            themeMode: _appState.themeMode,
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
