import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/listing_repository.dart';
import '../../domain/listing_model.dart';

final listingRepositoryProvider = Provider<ListingRepository>(
  (ref) => ListingRepository(),
);

final listingsProvider = FutureProvider.family<List<ListingModel>, Map<String, dynamic>>(
  (ref, filters) async {
    final repo = ref.watch(listingRepositoryProvider);
    return repo.getListings(
      city: filters['city'],
      type: filters['type'],
      maxPrice: filters['maxPrice'],
    );
  },
);

final myListingsProvider = FutureProvider<List<ListingModel>>(
  (ref) async {
    final repo = ref.watch(listingRepositoryProvider);
    return repo.getMyListings();
  },
);