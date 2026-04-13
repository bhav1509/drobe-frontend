import 'package:flutter/material.dart';
import '../app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _showAccountDialog(
    BuildContext context, {
    required String title,
    required String buttonLabel,
    required void Function(String value) onSubmit,
  }) async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Email or username'),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              Navigator.pop(dialogContext);
              onSubmit(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onSubmit(controller.text);
              },
              child: Text(buttonLabel),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Widget _surfaceCard(BuildContext context, {required Widget child}) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }

  Widget _iconChip(BuildContext context, IconData icon) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 22, color: scheme.onSurface),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return _surfaceCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _iconChip(context, icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(110, 46),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  ButtonStyle _segmentedStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.surface;
        }

        return Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.onSurface;
        }

        return scheme.onSurfaceVariant;
      }),
      side: WidgetStateProperty.all(BorderSide(color: scheme.outlineVariant)),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _contentRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _iconChip(context, icon),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: scheme.onSurfaceVariant,
          activeTrackColor: scheme.surfaceContainerHigh,
          inactiveThumbColor: scheme.onSurfaceVariant.withValues(alpha: 0.75),
          inactiveTrackColor: scheme.surface,
          trackOutlineColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.onSurfaceVariant.withValues(alpha: 0.65);
            }

            return scheme.outlineVariant;
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isLoggedIn = appState.accountStatus == AccountStatus.signedIn;

    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionCard(
            context,
            icon: Icons.person_outline,
            title: 'Account',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (isLoggedIn)
                  _actionButton(
                    context,
                    label: 'Logout',
                    onPressed: appState.logout,
                  )
                else ...[
                  _actionButton(
                    context,
                    label: 'Sign in',
                    onPressed: () {
                      _showAccountDialog(
                        context,
                        title: 'Sign in',
                        buttonLabel: 'Sign in',
                        onSubmit: appState.signIn,
                      );
                    },
                  ),
                  _actionButton(
                    context,
                    label: 'Sign up',
                    onPressed: () {
                      _showAccountDialog(
                        context,
                        title: 'Sign up',
                        buttonLabel: 'Create',
                        onSubmit: appState.signUp,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          _sectionCard(
            context,
            icon: Icons.palette_outlined,
            title: 'Appearance',
            child: SegmentedButton<ThemePreference>(
              style: _segmentedStyle(context),
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: ThemePreference.system,
                  label: Text('Auto'),
                ),
                ButtonSegment(
                  value: ThemePreference.light,
                  label: Text('Light'),
                ),
                ButtonSegment(value: ThemePreference.dark, label: Text('Dark')),
              ],
              selected: {appState.themePreference},
              onSelectionChanged: (selection) {
                appState.setThemePreference(selection.first);
              },
            ),
          ),
          const SizedBox(height: 18),
          _sectionCard(
            context,
            icon: Icons.tune_outlined,
            title: 'Content',
            child: Column(
              children: [
                _contentRow(
                  context,
                  icon: Icons.auto_awesome_outlined,
                  title: 'Show suggestions',
                  value: appState.isTabVisible(ContentTab.suggestions),
                  onChanged: (value) =>
                      appState.setTabVisibility(ContentTab.suggestions, value),
                ),
                const SizedBox(height: 14),
                _contentRow(
                  context,
                  icon: Icons.photo_library_outlined,
                  title: 'Show outfits',
                  value: appState.isTabVisible(ContentTab.outfits),
                  onChanged: (value) =>
                      appState.setTabVisibility(ContentTab.outfits, value),
                ),
                const SizedBox(height: 14),
                _contentRow(
                  context,
                  icon: Icons.checkroom_outlined,
                  title: 'Show wardrobe',
                  value: appState.isTabVisible(ContentTab.wardrobe),
                  onChanged: (value) =>
                      appState.setTabVisibility(ContentTab.wardrobe, value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
