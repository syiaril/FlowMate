import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/cycle_provider.dart';
import '../profile/profile_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final moodProvider = context.watch<MoodProvider>();
    final cycleProvider = context.watch<CycleProvider>();
    
    final partnerLinked = auth.profile?.partnerId != null;

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
                          child: ListTile(
                            leading: Image.network(e.mood, width: 40, height: 40),
                            title: const Text('Mood'),
                            subtitle: Text(e.note ?? ''),
                            trailing: Text('${e.date.day}/${e.date.month}/${e.date.year}'),
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}
