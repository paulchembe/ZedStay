import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../app.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZedStay'),
        backgroundColor: const Color(0xFF1B3A6B),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              ref.read(languageProvider.notifier).state =
                  lang == 'en' ? 'ny' : 'en';
            },
            child: Text(
              lang == 'en' ? 'NY' : 'EN',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              AppStrings.get('welcomeBack', lang),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Guest section
            const Text('Find a place',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    fontSize: 12)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => context.go('/search'),
              icon: const Icon(Icons.search),
              label: const Text('Find Accommodation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF185FA5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => context.go('/bookings'),
              icon: const Icon(Icons.book_online_outlined),
              label: const Text('My Bookings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B3A6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => context.go('/messages'),
              icon: const Icon(Icons.chat_outlined),
              label: const Text('Messages'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF534AB7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 24),

            // Host section
            const Text('Manage your property',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    fontSize: 12)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => context.go('/my-listings'),
              icon: const Icon(Icons.home_work_outlined),
              label: const Text('My Listings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F6E56),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => context.go('/create-listing'),
              icon: const Icon(Icons.add),
              label: const Text('Add New Listing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F6E56),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => context.go('/host-bookings'),
              icon: const Icon(Icons.inbox_outlined),
              label: const Text('Booking Requests'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA7517),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 24),

            // Admin section
            Consumer(
              builder: (context, ref, _) {
                return FutureBuilder(
                  future: Supabase.instance.client
                      .from('users')
                      .select('role')
                      .eq('id', user?.id ?? '')
                      .single(),
                  builder: (context, snapshot) {
                    if (snapshot.data?['role'] == 'admin') {
                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          const Text('Administration',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                  fontSize: 12)),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () =>
                                context.go('/admin'),
                            icon: const Icon(
                                Icons.admin_panel_settings),
                            label:
                                const Text('Admin Dashboard'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.red.shade700,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(
                                      vertical: 14),
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
          ],
        ),
      ),
    );
  }
}