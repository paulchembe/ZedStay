import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Admin stats provider
final adminStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final client = Supabase.instance.client;

  final users = await client.from('users').select('id');
  final listings = await client.from('listings').select('id');
  final bookings = await client.from('bookings').select('id');
  final reviews = await client.from('reviews').select('id');

  return {
    'users': (users as List).length,
    'listings': (listings as List).length,
    'bookings': (bookings as List).length,
    'reviews': (reviews as List).length,
  };
});

// Pending listings provider
final pendingListingsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    final client = Supabase.instance.client;
    final response = await client
        .from('listings')
        .select('*, users!host_id(full_name, email)')
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  },
);

// All users provider
final allUsersProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    final client = Supabase.instance.client;
    final response = await client
        .from('users')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  },
);

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateListingStatus(
      String listingId, String status) async {
    await Supabase.instance.client
        .from('listings')
        .update({'status': status}).eq('id', listingId);
    ref.invalidate(pendingListingsProvider);
    ref.invalidate(adminStatsProvider);
  }

  Future<void> _suspendUser(String userId) async {
    await Supabase.instance.client
        .from('users')
        .update({'role': 'suspended'}).eq('id', userId);
    ref.invalidate(allUsersProvider);
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(adminStatsProvider);
    final pendingListings = ref.watch(pendingListingsProvider);
    final allUsers = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF1B3A6B),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Listings'),
            Tab(text: 'Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Overview Tab ──
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Platform Overview',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                stats.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (data) => GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _StatCard(
                        label: 'Total Users',
                        value: data['users'].toString(),
                        icon: Icons.people_outlined,
                        color: const Color(0xFF1B3A6B),
                      ),
                      _StatCard(
                        label: 'Total Listings',
                        value: data['listings'].toString(),
                        icon: Icons.home_outlined,
                        color: const Color(0xFF0F6E56),
                      ),
                      _StatCard(
                        label: 'Total Bookings',
                        value: data['bookings'].toString(),
                        icon: Icons.book_online_outlined,
                        color: const Color(0xFFBA7517),
                      ),
                      _StatCard(
                        label: 'Total Reviews',
                        value: data['reviews'].toString(),
                        icon: Icons.star_outlined,
                        color: const Color(0xFF534AB7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Listings Tab ──
          pendingListings.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (listings) {
              if (listings.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 72, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No pending listings',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: listings.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final listing = listings[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(listing['title'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(listing['city'] ?? '',
                              style: const TextStyle(
                                  color: Colors.grey)),
                          Text(
                            'Host: ${listing['users']?['full_name'] ?? 'Unknown'}',
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      _updateListingStatus(
                                          listing['id'],
                                          'active'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        const Color(0xFF0F6E56),
                                    side: const BorderSide(
                                        color: Color(0xFF0F6E56)),
                                  ),
                                  child: const Text('Approve'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      _updateListingStatus(
                                          listing['id'],
                                          'inactive'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(
                                        color: Colors.red),
                                  ),
                                  child: const Text('Reject'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // ── Users Tab ──
          allUsers.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (users) => ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final user = users[index];
                final role = user['role'] ?? 'guest';
                final isSuspended = role == 'suspended';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1B3A6B),
                    child: Text(
                      (user['full_name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(user['full_name'] ?? 'Unknown'),
                  subtitle: Text(user['email'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSuspended
                              ? Colors.red.shade100
                              : const Color(0xFFD9F0EA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            color: isSuspended
                                ? Colors.red
                                : const Color(0xFF0F6E56),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (!isSuspended) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.block,
                              color: Colors.red, size: 20),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Suspend User'),
                              content: Text(
                                  'Suspend ${user['full_name']}?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _suspendUser(user['id']);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor:
                                          Colors.white),
                                  child: const Text('Suspend'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(label,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}