import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../auth/splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _partnerIdController = TextEditingController();
  bool _isUploading = false;

  Future<void> _showImageSourceSelector() async {
    final primary = Theme.of(context).colorScheme.primary;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Kamera',
                      source: ImageSource.camera,
                      primaryColor: primary,
                    ),
                    _buildSourceOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Galeri',
                      source: ImageSource.gallery,
                      primaryColor: primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required ImageSource source,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _uploadAvatar(source);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, color: primaryColor, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadAvatar(ImageSource source) async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: source,
      maxWidth: 300,
      maxHeight: 300,
    );

    if (imageFile == null) return;

    setState(() => _isUploading = true);

    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = fileName;

      // Upload to Supabase Storage
      await Supabase.instance.client.storage.from('avatars').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$fileExt'),
          );

      // Get public URL
      final imageUrlResponse = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // Update profile
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client
          .from('profiles')
          .update({'avatar_url': imageUrlResponse})
          .eq('id', userId);

      // Reload profile dynamically
      if (!mounted) return;
      await context.read<AuthProvider>().refreshProfile();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui foto profil: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _linkPartner() async {
    try {
      await SupabaseService.instance.updatePartnerId(_partnerIdController.text.trim());
      if (!mounted) return;
      await context.read<AuthProvider>().refreshProfile(); // refresh profile!
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partner ID updated!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to link partner: $e')),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout?'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);

    await authProvider.logout();

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;
    final user = auth.user;

    if (profile == null || user == null) {
      // After logout, profile becomes null — redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
          (route) => false,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _isUploading ? null : _showImageSourceSelector,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: _isUploading
                      ? const CircularProgressIndicator()
                      : (profile.avatarUrl == null ? const Icon(Icons.person, size: 50) : null),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Name: ${profile.name}', style: Theme.of(context).textTheme.titleLarge),
            Text('Email: ${profile.email}'),
            Text('Role: ${profile.role.toUpperCase()}'),
            const SizedBox(height: 24),
            Text('Your ID (Share with partner):', style: Theme.of(context).textTheme.titleMedium),
            SelectableText(user.id, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            const SizedBox(height: 16),
            Text('Link Partner', style: Theme.of(context).textTheme.titleMedium),
            TextField(
              controller: _partnerIdController..text = profile.partnerId ?? '',
              decoration: const InputDecoration(labelText: 'Partner ID'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _linkPartner,
              child: const Text('Save Partner ID'),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
