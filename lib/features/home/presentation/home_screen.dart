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
          title: Row(children: [
            Image.asset('assets/netraone_logo_final.png', height: 35),
            const SizedBox(width: 10),
            const Text('NETRAONE',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1))
          ]),
          actions: [
            PopupMenuButton<String>(
                onSelected: (choice) async {
                  if (choice == 'logout') {
                    try {
                      await api.logout();
                    } catch (e) {
                      if (context.mounted)
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('$e')));
                    }
                    widget.onLogout();
                  }
                  if (choice == 'profile' && context.mounted)
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProfileScreen()));
                  if (choice == 'menu' && context.mounted)
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MenuScreen(screens: screens)));
                },
                itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'profile', child: Text('Profil')),
                      const PopupMenuItem(
                          value: 'menu', child: Text('Semua menu')),
                      const PopupMenuItem(
                          value: 'logout', child: Text('Keluar')),
                    ])
          ]),
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
              .toList()),
    );
  }
}
