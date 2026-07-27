import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/listing_repository.dart';
import '../../domain/listing_model.dart';

final listingRepositoryProvider = Provider<ListingRepository>(
  (ref) => ListingRepository(),
);

// Use individual parameters instead of a Map to avoid infinite loops
final listingsProvider = FutureProvider.family<List<ListingModel>, String>(
  (ref, filterKey) async {
    final repo = ref.watch(listingRepositoryProvider);
    // Parse the filterKey string back to parameters
    final parts = filterKey.split('|');
    final city = parts[0].isEmpty ? null : parts[0];
    final type = parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null;
    final maxPrice = parts.length > 2 && parts[2].isNotEmpty
        ? double.tryParse(parts[2])
        : null;

    return repo.getListings(
      city: city,
      type: type,
      maxPrice: maxPrice,
    );
  },
);

final myListingsProvider = FutureProvider<List<ListingModel>>(
  (ref) async {
    final repo = ref.watch(listingRepositoryProvider);
    return repo.getMyListings();
  },
);