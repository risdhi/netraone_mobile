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
    final userName = api.me?['name']?.toString().trim();
    final highPriorityEvents = events.where((event) {
      final severity = '${event['severity'] ?? ''}'.toLowerCase();
      return severity == 'high' || severity == 'critical';
    }).length;

    return RefreshIndicator(
      onRefresh: reload,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Text('Selamat datang,', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 3),
          Text(
            userName == null || userName.isEmpty ? 'NetraOne' : userName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: picotelMint,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user_outlined, size: 15, color: navy),
                const SizedBox(width: 6),
                Text(
                  roleName(widget.role),
                  style: const TextStyle(
                    color: navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 23),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [picotelDark, navy, Color(0xFF126C72)],
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.remove_red_eye_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pantau lebih cerdas',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 7),
                            Text(
                              'Satu ruang untuk melihat aktivitas keamanan yang relevan dengan akses Anda.',
                              style: TextStyle(
                                color: Color(0xFFD5E9E8),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 16),
                            _AccessBadge(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: -42,
                  top: -56,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Event dimuat',
                  value: loading ? '—' : '${events.length}',
                  icon: Icons.insights_outlined,
                  color: blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'Prioritas tinggi',
                  value: loading ? '—' : '$highPriorityEvents',
                  icon: Icons.priority_high_rounded,
                  color: warningColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Aktivitas terkini',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Event terbaru yang tersedia untuk akun Anda',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            )
          else if (error != null)
            ErrorPanel(error!, reload)
          else if (events.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: picotelMint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: navy),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Semua tenang',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Belum ada event yang dapat ditampilkan.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            )
          else
            ...events.map((event) => EventTile(event: event)),
        ],
      ),
    );
  }
}

class _AccessBadge extends StatelessWidget {
  const _AccessBadge();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, color: Color(0xFFD5E9E8), size: 13),
            SizedBox(width: 6),
            Text(
              'AKSES TERLINDUNGI',
              style: TextStyle(
                color: Color(0xFFD5E9E8),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      );
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const Spacer(),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Text(
              value,
              style: const TextStyle(
                color: ink,
                fontSize: 25,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: mutedInk, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
}
