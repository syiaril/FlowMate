import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _friendlyError(Object e) {
    final raw = e.toString().toLowerCase();
    if (raw.contains('invalid login credentials') || raw.contains('invalid_credentials')) {
      return 'Email atau password salah.';
    }
    if (raw.contains('email not confirmed')) {
      return 'Email belum diverifikasi. Cek inbox kamu.';
    }
    if (raw.contains('rate limit') || raw.contains('over_email_send_rate_limit')) {
      return 'Terlalu banyak percobaan. Coba lagi nanti.';
    }
    if (raw.contains('network') || raw.contains('socket') || raw.contains('connection')) {
      return 'Tidak ada koneksi internet. Periksa jaringan kamu.';
    }
    if (raw.contains('user not found')) {
      return 'Akun tidak ditemukan. Daftar dulu ya!';
    }
    return 'Gagal masuk. Silakan coba lagi.';
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(email);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    } catch (e) {
      if (!mounted) return;
      final errMsg = _friendlyError(e);
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.error_rounded, color: Color(0xFFE53935), size: 56),
          title: const Text('Login Gagal', textAlign: TextAlign.center),
          content: Text(errMsg, textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Masuk'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Icon(Icons.favorite_rounded, size: 64, color: primary),
                const SizedBox(height: 12),
                Text(
                  'Selamat Datang!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Masuk ke akunmu untuk melanjutkan',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 36),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
                    if (!_isValidEmail(v.trim())) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Login Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text('Masuk',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Belum punya akun? ',
                        style: TextStyle(color: Colors.grey.shade600)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        'Daftar',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
