import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';

class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({super.key});

  void _handleSelection(BuildContext context, String value) {
    if (value == 'settings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
      return;
    }

    if (value == 'logout') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logout is not wired yet')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleSelection(context, value),
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
    );
  }
}
