import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/booking_provider.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: bookings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_online_outlined,
                      size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No bookings yet',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Text('Search for accommodation to make your first booking',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final booking = list[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              booking.listingTitle ?? 'Listing',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),
                          _StatusBadge(status: booking.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(booking.listingCity ?? '',
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatDate(booking.checkIn)} → ${_formatDate(booking.checkOut)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${booking.totalNights} nights · K ${booking.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Color(0xFF0F6E56),
                            fontWeight: FontWeight.w500),
                      ),
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

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'pending': Colors.orange,
      'confirmed': const Color(0xFF0F6E56),
      'cancelled': Colors.red,
      'completed': const Color(0xFF1B3A6B),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (colors[status] ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors[status] ?? Colors.grey),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
            color: colors[status] ?? Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}