import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/listing_provider.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myListings = ref.watch(myListingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/create-listing'),
        backgroundColor: const Color(0xFF1B3A6B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New listing',
            style: TextStyle(color: Colors.white)),
      ),
      body: myListings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (listings) {
          if (listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home_work_outlined,
                      size: 72, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No listings yet',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  const Text('Tap the button below to add your first property',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final listing = listings[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  
                  onTap: () => context.go(
                    '/listing-detail',
                    extra: listing,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  leading: listing.photoUrls.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            listing.photoUrls.first,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.home_outlined,
                              color: Colors.grey),
                        ),
                  title: Text(listing.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(listing.city),
                      Text('K ${listing.pricePerNight.toStringAsFixed(0)}/night',
                          style: const TextStyle(
                              color: Color(0xFF0F6E56),
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      final repo = ref.read(listingRepositoryProvider);
                      if (value == 'delete') {
                        await repo.deleteListing(listing.id);
                        ref.invalidate(myListingsProvider);
                      } else if (value == 'deactivate') {
                        await repo.toggleListingStatus(listing.id, 'inactive');
                        ref.invalidate(myListingsProvider);
                      } else if (value == 'activate') {
                        await repo.toggleListingStatus(listing.id, 'active');
                        ref.invalidate(myListingsProvider);
                      }
                    },
                    itemBuilder: (_) => [
                      if (listing.status == 'active')
                        const PopupMenuItem(
                            value: 'deactivate',
                            child: Text('Deactivate')),
                      if (listing.status == 'inactive')
                        const PopupMenuItem(
                            value: 'activate', child: Text('Activate')),
                      const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}