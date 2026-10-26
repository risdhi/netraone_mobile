import 'package:flutter/material.dart';
import '../../../core/shared.dart';
import '../../resources/presentation/resource_screens.dart';
import '../../profile/presentation/profile_screens.dart';

class MenuScreen extends StatelessWidget {
  final List<ScreenSpec> screens;
  const MenuScreen({super.key, required this.screens});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            'Menu NetraOne',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        ...screens.map((screen) {
          return Card(
            child: ListTile(
              leading: Icon(screen.icon, color: blue),
              title: Text(screen.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => screen.resource == 'profile'
                        ? const ProfileScreen()
                        : ResourceScreen(spec: screen),
                  ),
                );
              },
            ),
          );
        }),
        Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ),
      ],
    );
  }
}
