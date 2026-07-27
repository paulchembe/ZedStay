import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/booking_model.dart';

class BookingRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Check if dates are available for a listing
  Future<bool> areDatesAvailable(
      String listingId, DateTime checkIn, DateTime checkOut) async {
    final days = checkOut.difference(checkIn).inDays;
    final datesToCheck = List.generate(
      days,
      (i) => checkIn.add(Duration(days: i)).toIso8601String().split('T')[0],
    );

    final response = await _client
        .from('availability')
        .select('blocked_date')
        .eq('listing_id', listingId)
        .inFilter('blocked_date', datesToCheck);

    return (response as List).isEmpty;
  }

  // Create a booking request
  Future<BookingModel> createBooking({
    required String listingId,
    required String hostId,
    required DateTime checkIn,
    required DateTime checkOut,
    required double pricePerNight,
    String? guestMessage,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final nights = checkOut.difference(checkIn).inDays;
    final totalPrice = nights * pricePerNight;

    // Check availability first
    final available = await areDatesAvailable(listingId, checkIn, checkOut);
    if (!available) throw Exception('Selected dates are not available');

    final response = await _client.from('bookings').insert({
      'listing_id': listingId,
      'guest_id': user.id,
      'host_id': hostId,
      'check_in': checkIn.toIso8601String().split('T')[0],
      'check_out': checkOut.toIso8601String().split('T')[0],
      'total_price': totalPrice,
      'status': 'pending',
      'guest_message': guestMessage,
    }).select('''
      *,
      listings(title, city, listing_photos(photo_url)),
      guest:users!guest_id(full_name, email)
    ''').single();

    return BookingModel.fromJson(response);
  }

  // Host accepts or declines a booking
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _client
        .from('bookings')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', bookingId);

    // If confirmed, block the dates in availability table
    if (status == 'confirmed') {
      final booking = await _client
          .from('bookings')
          .select()
          .eq('id', bookingId)
          .single();

      final checkIn = DateTime.parse(booking['check_in']);
      final checkOut = DateTime.parse(booking['check_out']);
      final days = checkOut.difference(checkIn).inDays;

      final blockedDates = List.generate(days, (i) {
        final date = checkIn.add(Duration(days: i));
        return {
          'listing_id': booking['listing_id'],
          'blocked_date': date.toIso8601String().split('T')[0],
          'booking_id': bookingId,
        };
      });

      await _client.from('availability').insert(blockedDates);
    }
  }

  // Get bookings for guest
  Future<List<BookingModel>> getMyBookings() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await _client
        .from('bookings')
        .select('''
          *,
          listings(title, city, listing_photos(photo_url)),
          guest:users!guest_id(full_name, email)
        ''')
        .eq('guest_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).map((j) => BookingModel.fromJson(j)).toList();
  }

  // Get bookings for host
  Future<List<BookingModel>> getHostBookings() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await _client
        .from('bookings')
        .select('''
          *,
          listings(title, city, listing_photos(photo_url)),
          guest:users!guest_id(full_name, email)
        ''')
        .eq('host_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).map((j) => BookingModel.fromJson(j)).toList();
  }

  // Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    await _client
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);

    // Unblock dates
    await _client
        .from('availability')
        .delete()
        .eq('booking_id', bookingId);
  }
}