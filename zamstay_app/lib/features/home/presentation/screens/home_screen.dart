import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZedStay'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/login');
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to ZedStay!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Logged in as: ${user?.email ?? "unknown"}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/my-listings'),
              icon: const Icon(Icons.home_work_outlined),
              label: const Text('My Listings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B3A6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.go('/create-listing'),
              icon: const Icon(Icons.add),
              label: const Text('Add New Listing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F6E56),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.go('/search'),
              icon: const Icon(Icons.search),
              label: const Text('Find Accommodation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF185FA5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
            // Add this below the other buttons
            Consumer(
              builder: (context, ref, _) {
                final user = Supabase.instance.client.auth.currentUser;
                // Check role from metadata or users table
                return FutureBuilder(
                  future: Supabase.instance.client
                      .from('users')
                      .select('role')
                      .eq('id', user?.id ?? '')
                      .single(),
                  builder: (context, snapshot) {
                    if (snapshot.data?['role'] == 'admin') {
                      return Column(
                        children: [
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/admin'),
                            icon: const Icon(Icons.admin_panel_settings),
                            label: const Text('Admin Dashboard'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                );
              },
),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.go('/bookings'),
              icon: const Icon(Icons.book_online_outlined),
              label: const Text('My Bookings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF185FA5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}