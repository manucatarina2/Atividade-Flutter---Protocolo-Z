import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/auth/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final profile = auth.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              child: Text(
                (profile?.nickname ?? '?').substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(profile?.nickname ?? '-',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (profile?.faction != null)
            Center(
                child: Chip(
                    label: Text(
                        '${profile!.faction!.symbol} ${profile.faction!.name}'))),
          const SizedBox(height: 8),
          Center(child: Text('Reputação: ${profile?.reputation ?? 0}')),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900),
          ),
        ],
      ),
    );
  }
}
