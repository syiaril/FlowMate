import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/date_utils.dart';
import '../profile/profile_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _showSendMessageDialog(BuildContext context, String partnerId) {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kirim Pesan ke Partner'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Misal: Jangan lupa minum air!',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final message = textController.text.trim();
              if (message.isNotEmpty) {
                try {
                  await SupabaseService.instance.sendPartnerMessage(partnerId, message);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pesan berhasil terkirim! 💌')),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal mengirim pesan: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final moodProvider = context.watch<MoodProvider>();
    final cycleProvider = context.watch<CycleProvider>();
    
    final partnerLinked = auth.profile?.partnerId != null;
    final partnerId = auth.profile?.partnerId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          )
        ],
      ),
      floatingActionButton: partnerLinked && partnerId != null
          ? FloatingActionButton.extended(
              onPressed: () => _showSendMessageDialog(context, partnerId),
              icon: const Icon(Icons.favorite),
              label: const Text('Kirim Pesan'),
              backgroundColor: Colors.pink.shade300,
              foregroundColor: Colors.white,
            )
          : null,
      body: !partnerLinked
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Anda belum terhubung dengan Partner.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                    },
                    child: const Text('Hubungkan Partner'),
                  )
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await moodProvider.loadEntries();
                await cycleProvider.loadCycles();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Status Partner', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      title: const Text('Fase Siklus Saat Ini'),
                      subtitle: Text(
                        cycleProvider.currentPhase.isNotEmpty
                            ? cycleProvider.currentPhase.toUpperCase()
                            : 'Belum ada data',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Mood Terakhir', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (moodProvider.entries.isEmpty)
                    const Text('Belum ada data mood.')
                  else
                    ...moodProvider.entries.take(5).map((e) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Mood Icon & Time
                                Column(
                                  children: [
                                    (e.imageUrl != null && e.imageUrl!.isNotEmpty)
                                        ? Image.network(e.imageUrl!, width: 40, height: 40, fit: BoxFit.contain)
                                        : (e.mood.startsWith('http')
                                            ? Image.network(e.mood, width: 40, height: 40, fit: BoxFit.contain)
                                            : Text(e.mood, style: const TextStyle(fontSize: 36))),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        FlowDateUtils.formatTime(e.date),
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            (e.mood.isNotEmpty && !e.mood.startsWith('http'))
                                                ? e.mood
                                                : 'Mood Tercatat',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade900,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            FlowDateUtils.formatDateShort(e.date),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if (e.symptoms.isNotEmpty)
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: e.symptoms.map((s) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              s,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Theme.of(context).colorScheme.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          )).toList(),
                                        ),
                                      if (e.note != null && e.note!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          e.note!,
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}
