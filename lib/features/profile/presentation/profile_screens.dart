import 'package:flutter/material.dart';
import '../../../core/shared.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = api.me ?? const <String, dynamic>{};
    const visibleFields = ['company_name'];
    final fields = visibleFields.where((field) => user[field] != null).toList();
    final name = v(user['name']);
    final email = v(user['email']);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [picotelDark, navy, Color(0xFF126C72)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                    size: 31,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name == '—' ? 'Pengguna NetraOne' : name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    color: Color(0xFFD5E9E8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    roleName('${user['role']}'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'Informasi akun',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          for (final field in fields)
            Card(
              child: ListTile(
                leading: const Icon(Icons.business_outlined, color: blue),
                title: Text(
                  fieldTitle(field),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    v(user[field]),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
          if (fields.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('Informasi perusahaan tidak tersedia.'),
              ),
            ),
          const SizedBox(height: 10),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline_rounded, color: blue),
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
