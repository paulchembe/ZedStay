import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/listing_model.dart';

class ListingDetailScreen extends ConsumerWidget {
  final ListingModel listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: Colors.black),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: listing.photoUrls.isNotEmpty
                  ? Image.network(
                      listing.photoUrls.first,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: const Color(0xFFD6E4F7),
                      child: const Icon(Icons.home_outlined,
                          size: 80, color: Color(0xFF1B3A6B)),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(listing.title,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'K ${listing.pricePerNight.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F6E56)),
                          ),
                          const Text('per night',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                            '${listing.city} · ${listing.address}',
                            style:
                                const TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6E4F7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          listing.type[0].toUpperCase() +
                              listing.type.substring(1),
                          style: const TextStyle(
                              color: Color(0xFF1B3A6B), fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.bed_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${listing.rooms} rooms',
                          style:
                              const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('About this place',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(listing.description,
                      style: const TextStyle(
                          height: 1.6, color: Colors.black87)),
                  const SizedBox(height: 24),
                  if (listing.amenities.isNotEmpty) ...[
                    const Text('Amenities',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: listing.amenities.map((a) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(a,
                              style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (listing.photoUrls.length > 1) ...[
                    const Text('Photos',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: listing.photoUrls.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              listing.photoUrls[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => context.push(
            '/book-request',
            extra: {
              'hostId': listing.hostId,
              'listingTitle': listing.title,
              'listingCity': listing.city,
              'pricePerNight': listing.pricePerNight,
            },
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B3A6B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Book Now',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}