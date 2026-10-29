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
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE7F3F1), canvas, Color(0xFFF7F8FA)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 30,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    children: [
                      const Brand(height: 106),
                      const SizedBox(height: 26),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: picotelMint,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.lock_open_rounded,
                                  color: navy,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Selamat datang',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Masuk untuk melanjutkan ke dashboard pemantauan Anda.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: email,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Alamat email',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: password,
                                obscureText: true,
                                onSubmitted: (_) => busy ? null : submit(),
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.key_rounded),
                                ),
                              ),
                              if (error != null)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(top: 14),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0ED),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    error!,
                                    style: const TextStyle(
                                      color: errorColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: busy ? null : submit,
                                  child: busy
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('Masuk ke akun'),
                                            SizedBox(width: 8),
                                            Icon(Icons.arrow_forward_rounded,
                                                size: 18),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.shield_outlined,
                                      color: mutedInk, size: 15),
                                  SizedBox(width: 6),
                                  Text(
                                    'AI Video Monitoring  •  Secure Access',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: mutedInk,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'NETRAONE  •  SMARTER SECURITY',
                        style: TextStyle(
                          color: mutedInk,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
