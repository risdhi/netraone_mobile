import 'package:flutter/material.dart';
import '../core/shared.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/home_screen.dart';

class NetraApp extends StatefulWidget {
  const NetraApp({super.key});
  @override
  State<NetraApp> createState() => _NetraAppState();
}

class _NetraAppState extends State<NetraApp> {
  bool loading = true;
  String? restoreError;
  @override
  void initState() {
    super.initState();
    api.onUnauthorized = refresh;
    _restore();
  }

  Future<void> _restore() async {
    try {
      await api.restore();
    } catch (e) {
      restoreError = '$e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'NetraOne',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: loading
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : api.me == null
                ? LoginScreen(onLogin: refresh, initialError: restoreError)
                : HomeScreen(onLogout: refresh),
      );
}
