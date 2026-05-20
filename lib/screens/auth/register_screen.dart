import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedRole = 'partner';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _friendlyError(Object e) {
    final raw = e.toString().toLowerCase();
    if (raw.contains('rate limit') || raw.contains('over_email_send_rate_limit')) {
      return 'Terlalu banyak percobaan. Coba lagi beberapa menit lagi.';
    }
    if (raw.contains('email already') || raw.contains('already registered') || raw.contains('user_already_exists')) {
      return 'Email ini sudah terdaftar. Coba login.';
    }
    if (raw.contains('invalid email') || raw.contains('invalid_email')) {
      return 'Format email tidak valid.';
    }
    if (raw.contains('password') && raw.contains('short')) {
      return 'Password terlalu pendek, minimal 6 karakter.';
    }
    if (raw.contains('network') || raw.contains('socket') || raw.contains('connection')) {
      return 'Tidak ada koneksi internet. Periksa jaringan kamu.';
    }
    if (raw.contains('invalid login credentials') || raw.contains('invalid_credentials')) {
      return 'Email atau password salah.';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(email);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().register(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
            _selectedRole,
          );
      if (!mounted) return;
      // Show success message then go back
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 56),
          title: const Text('Registrasi Berhasil!', textAlign: TextAlign.center),
          content: const Text(
            'Akun kamu berhasil dibuat.\nSilakan cek email untuk verifikasi (jika diperlukan).',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // go back to login
              },
              child: const Text('Masuk Sekarang'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final errMsg = _friendlyError(e);
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.error_rounded, color: Color(0xFFE53935), size: 56),
          title: const Text('Registrasi Gagal', textAlign: TextAlign.center),
          content: Text(
            errMsg.isNotEmpty ? errMsg : 'Terjadi kesalahan. Coba lagi.',
            textAlign: TextAlign.center,
          ),
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
        title: const Text('Buat Akun'),
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
                  'Buat akun untuk mulai melacak siklus kamu',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 36),

                // Name
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: const Icon(Icons.person_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Nama tidak boleh kosong';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

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
                  onFieldSubmitted: (_) => _register(),
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
                    if (v.length < 6) return 'Password minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Tipe Akun Section
                Text(
                  'Tipe Akun',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildRoleCard(
                        role: 'partner',
                        title: 'Pelacak',
                        subtitle: 'Lacak siklus saya sendiri',
                        icon: Icons.favorite_rounded,
                        primaryColor: primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRoleCard(
                        role: 'admin',
                        title: 'Pemantau',
                        subtitle: 'Pantau siklus pasangan',
                        icon: Icons.supervised_user_circle_rounded,
                        primaryColor: primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
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
                        : const Text('Daftar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),

                // Back to login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sudah punya akun? ',
                        style: TextStyle(color: Colors.grey.shade600)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Masuk',
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

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primaryColor,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : Colors.grey.shade400,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? primaryColor : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
