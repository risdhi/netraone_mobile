import 'package:flutter/material.dart';
import '../../../core/shared.dart';
import '../../resources/presentation/resource_screens.dart';

class DashboardScreen extends StatefulWidget {
  final String role;
  const DashboardScreen({super.key, required this.role});
  @override
  State<DashboardScreen> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardScreen> {
  List<Map<String, dynamic>> events = [];
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await api.page('events', page: 1, perPage: 10);
      final items = response['data'] as List;
      if (mounted) {
        setState(() {
          events = items
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: reload,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.role == 'platform_admin'
                ? 'Dashboard Platform'
                : widget.role == 'member_admin'
                    ? 'Dashboard Perusahaan'
                    : 'Home Monitoring',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Selamat datang, ${v(api.me?['name'])} · ${roleName(widget.role)}',
            style: const TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [picotelDark, navy, blue],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Colors.white, size: 35),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monitor · Analyze · Respond',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pantau event sesuai akses yang diberikan server.',
                        style: TextStyle(
                          color: Color(0xFFE4F9F7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Event Terbaru',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (error != null)
            ErrorPanel(error!, reload)
          else if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Belum ada event yang dapat ditampilkan.'),
            )
          else
            ...events.map((event) => EventTile(event: event)),
        ],
      ),
    );
  }
}
