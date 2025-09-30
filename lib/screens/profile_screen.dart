import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Kijelentkezés',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Profil kép és alapadatok
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user?.userMetadata?['avatar_url'] != null
                      ? NetworkImage(user!.userMetadata!['avatar_url'])
                      : null,
                  child: user?.userMetadata?['avatar_url'] == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.userMetadata?['full_name'] ?? 'Névtelen felhasználó',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Nincs email',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            // Felhasználói információk
            const Text(
              'Felhasználói információk',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildInfoCard(
              'Felhasználó ID',
              user?.id ?? 'N/A',
              Icons.person_outline,
            ),
            const SizedBox(height: 12),
            
            _buildInfoCard(
              'Email',
              user?.email ?? 'N/A',
              Icons.email_outlined,
            ),
            const SizedBox(height: 12),
            
            _buildInfoCard(
              'Utolsó bejelentkezés',
              user?.lastSignInAt != null
                  ? DateTime.parse(user!.lastSignInAt!).toLocal().toString()
                  : 'N/A',
              Icons.access_time,
            ),
            const SizedBox(height: 12),
            
            _buildInfoCard(
              'Fiók létrehozva',
              user?.createdAt != null
                  ? DateTime.parse(user!.createdAt).toLocal().toString()
                  : 'N/A',
              Icons.calendar_today,
            ),
            
            const Spacer(),
            
            // Kijelentkezés gomb
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await AuthService.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Kijelentkezés'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
