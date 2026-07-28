import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/listing_model.dart';
import '../../../core/storage/local_storage.dart' as app_storage;

class ListingRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Get all listings with offline support
  Future<List<ListingModel>> getListings({
    String? city,
    String? type,
    double? maxPrice,
  }) async {
    final cacheKey =
        '${city ?? ''}_${type ?? ''}_${maxPrice ?? ''}';

    try {
      final connectivityResult =
          await Connectivity().checkConnectivity();
      final isOnline =
          connectivityResult != ConnectivityResult.none;

      if (!isOnline) {
        final cached =
            app_storage.LocalStorage.getCachedListings(cacheKey);
        if (cached != null) {
          return cached
              .map((json) => ListingModel.fromJson(json))
              .toList();
        }
        throw Exception('No internet and no cached data');
      }

      var query = _client
          .from('listings')
          .select('*, listing_photos(*)')
          .eq('status', 'active');

      if (city != null && city.isNotEmpty) {
        query = query.ilike('city', '%$city%');
      }
      if (type != null && type.isNotEmpty) {
        query = query.eq('type', type);
      }
      if (maxPrice != null) {
        query = query.lte('price_per_night', maxPrice);
      }

      final response =
          await query.order('created_at', ascending: false);
      final listings =
          List<Map<String, dynamic>>.from(response);

      await app_storage.LocalStorage.cacheListings(
          cacheKey, listings);

      return listings
          .map((json) => ListingModel.fromJson(json))
          .toList();
    } catch (e) {
      final cached =
          app_storage.LocalStorage.getCachedListings(cacheKey);
      if (cached != null) {
        return cached
            .map((json) => ListingModel.fromJson(json))
            .toList();
      }
      rethrow;
    }
  }

  Future<String> createListing({
    required String title,
    required String description,
    required String type,
    required String city,
    required String address,
    required double pricePerNight,
    required int rooms,
    required List<String> amenities,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await _client.from('listings').insert({
      'host_id': user.id,
      'title': title,
      'description': description,
      'type': type,
      'city': city,
      'address': address,
      'price_per_night': pricePerNight,
      'rooms': rooms,
      'amenities': amenities,
      'status': 'active',
    }).select().single();

    return response['id'];
  }

  Future<String> uploadPhoto(
      String listingId, Uint8List bytes, String fileName) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final path = '${user.id}/$listingId/$fileName';

    await _client.storage.from('listing-photos').uploadBinary(
          path,
          bytes,
          fileOptions:
              const FileOptions(contentType: 'image/jpeg'),
        );

    return _client.storage
        .from('listing-photos')
        .getPublicUrl(path);
  }

  Future<void> savePhotoRecord(String listingId, String photoUrl,
      bool isPrimary, int orderIndex) async {
    await _client.from('listing_photos').insert({
      'listing_id': listingId,
      'photo_url': photoUrl,
      'is_primary': isPrimary,
      'order_index': orderIndex,
    });
  }

  Future<List<ListingModel>> getMyListings() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await _client
        .from('listings')
        .select('*, listing_photos(*)')
        .eq('host_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ListingModel.fromJson(json))
        .toList();
  }

  Future<void> deleteListing(String listingId) async {
    await _client.from('listings').delete().eq('id', listingId);
  }

  Future<void> toggleListingStatus(
      String listingId, String status) async {
    await _client
        .from('listings')
        .update({'status': status}).eq('id', listingId);
  }
}