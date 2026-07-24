import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/booking_repository.dart';
import '../../domain/booking_model.dart';

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => BookingRepository(),
);

final myBookingsProvider = FutureProvider<List<BookingModel>>(
  (ref) => ref.watch(bookingRepositoryProvider).getMyBookings(),
);

final hostBookingsProvider = FutureProvider<List<BookingModel>>(
  (ref) => ref.watch(bookingRepositoryProvider).getHostBookings(),
);