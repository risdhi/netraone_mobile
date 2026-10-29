import 'package:flutter/material.dart';
import '../../../core/shared.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../menu/presentation/menu_screen.dart';
import '../../resources/presentation/resource_screens.dart';
import '../../profile/presentation/profile_screens.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const HomeScreen({super.key, required this.onLogout});
  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  int selected = 0;
  String get role => '${api.me?['role'] ?? 'member_user'}';
  List<ScreenSpec> get screens => roleScreens(role);
  List<ScreenSpec> get tabs => [
        const ScreenSpec('Home', 'dashboard', Icons.home_outlined),
        const ScreenSpec(
            'AI Event', 'events', Icons.notifications_active_outlined),
        const ScreenSpec('Kamera', 'cameras', Icons.videocam_outlined),
        const ScreenSpec(
            'Notifikasi', 'notifications', Icons.notifications_outlined),
      ];
  @override
  Widget build(BuildContext context) {
    final current = tabs[selected];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 66,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/netraone_logo_final.png', height: 38),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NETRAONE',
                  style: TextStyle(
                    fontSize: 15,
                    color: navy,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  'AI VIDEO MONITORING',
                  style: TextStyle(
                    fontSize: 9,
                    color: mutedInk,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Akun dan menu',
            icon: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: picotelMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline_rounded, color: navy),
            ),
            onSelected: (choice) async {
              if (choice == 'logout') {
                try {
                  await api.logout();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('$e')));
                  }
                }
                widget.onLogout();
              }
              if (choice == 'profile' && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              }
              if (choice == 'menu' && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MenuScreen(screens: screens)),
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'profile', child: Text('Profil')),
              const PopupMenuItem(value: 'menu', child: Text('Semua menu')),
              const PopupMenuItem(value: 'logout', child: Text('Keluar')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: current.resource == 'dashboard'
          ? DashboardScreen(role: role)
          : ResourceScreen(
              key: ValueKey(current.resource), spec: current, embedded: true),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (i) => setState(() => selected = i),
        destinations: tabs
            .map((s) =>
                NavigationDestination(icon: Icon(s.icon), label: s.title))
            .toList(),
      ),
    );
  }
}
