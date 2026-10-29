import 'package:flutter/material.dart';
import '../../../core/shared.dart';
import '../../resources/presentation/resource_screens.dart';
import '../../profile/presentation/profile_screens.dart';

class MenuScreen extends StatelessWidget {
  final List<ScreenSpec> screens;
  const MenuScreen({super.key, required this.screens});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Semua menu')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            'Akses cepat',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 5),
          Text(
            'Pilih area yang ingin Anda kelola.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ...screens.where((screen) => screen.resource != 'profile').map((screen) {
            return Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: picotelMint,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(screen.icon, color: blue, size: 21),
                ),
                title: Text(
                  screen.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  screen.writable ? 'Lihat dan kelola data' : 'Lihat data',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
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
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: picotelMint,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.person_outline_rounded, color: blue),
              ),
              title: const Text(
                'Profil saya',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Informasi akun',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
