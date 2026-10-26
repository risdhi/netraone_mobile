import 'package:flutter/material.dart';
import '../../../core/shared.dart';
import '../../../shared/widgets/brand.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = api.me ?? const <String, dynamic>{};
    const visibleFields = ['name', 'email', 'role', 'company_name'];
    final fields = visibleFields.where((field) => user[field] != null).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: Brand(height: 80)),
          const SizedBox(height: 16),
          for (final field in fields)
            Card(
              child: ListTile(
                title: Text(fieldTitle(field)),
                subtitle: Text(field == 'role'
                    ? roleName('${user[field]}')
                    : v(user[field])),
              ),
            ),
          if (fields.isEmpty)
            const Center(child: Text('Informasi profil tidak tersedia.')),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Pengaturan profil belum tersedia.'),
              subtitle: Text(
                'API saat ini hanya menyediakan pembacaan identitas akun.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
