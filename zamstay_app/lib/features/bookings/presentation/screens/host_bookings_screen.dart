import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/booking_provider.dart';

class HostBookingsScreen extends ConsumerWidget {
  const HostBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(hostBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests'),
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
                  Icon(Icons.inbox_outlined, size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No booking requests yet',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500)),
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
                              booking.guestName ?? 'Guest',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),
                          _StatusBadge(status: booking.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(booking.guestEmail ?? '',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(booking.listingTitle ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(booking.checkIn)} → ${_formatDate(booking.checkOut)} · ${booking.totalNights} nights',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        'K ${booking.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Color(0xFF0F6E56),
                            fontWeight: FontWeight.w500),
                      ),
                      if (booking.guestMessage != null) ...[
                        const SizedBox(height: 8),
                        Text('"${booking.guestMessage}"',
                            style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey)),
                      ],
                      if (booking.isPending) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await ref
                                      .read(bookingRepositoryProvider)
                                      .updateBookingStatus(
                                          booking.id, 'cancelled');
                                  ref.invalidate(hostBookingsProvider);
                                },
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red)),
                                child: const Text('Decline'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await ref
                                      .read(bookingRepositoryProvider)
                                      .updateBookingStatus(
                                          booking.id, 'confirmed');
                                  ref.invalidate(hostBookingsProvider);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F6E56),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Accept'),
                              ),
                            ),
                          ],
                        ),
                      ],
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