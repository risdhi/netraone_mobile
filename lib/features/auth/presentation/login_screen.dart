import 'package:flutter/material.dart';
import '../../../core/shared.dart';
import '../../../shared/widgets/brand.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  final String? initialError;
  const LoginScreen({super.key, required this.onLogin, this.initialError});
  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final email = TextEditingController(), password = TextEditingController();
  bool busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    error = widget.initialError;
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (email.text.trim().isEmpty || !email.text.contains('@')) {
      setState(() => error = 'Masukkan alamat email yang valid.');
      return;
    }
    if (password.text.isEmpty) {
      setState(() => error = 'Password wajib diisi.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await api.login(email.text.trim(), password.text);
      widget.onLogin();
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Center(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                      child: Padding(
                          padding: const EdgeInsets.all(24),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            const Brand(height: 116),
                            const SizedBox(height: 18),
                            const Text('Selamat Datang',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            TextField(
                                controller: email,
                                keyboardType: TextInputType.emailAddress,
                                decoration:
                                    const InputDecoration(labelText: 'Email')),
                            const SizedBox(height: 12),
                            TextField(
                                controller: password,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    labelText: 'Password')),
                            if (error != null)
                              Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(error!,
                                      style:
                                          const TextStyle(color: Colors.red))),
                            const SizedBox(height: 18),
                            SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                    onPressed: busy ? null : submit,
                                    child:
                                        Text(busy ? 'Memproses...' : 'Masuk'))),
                            const SizedBox(height: 10),
                            const Text('AI Video Monitoring â€¢ Secure Access',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.blueGrey)),
                          ])))))));
}
