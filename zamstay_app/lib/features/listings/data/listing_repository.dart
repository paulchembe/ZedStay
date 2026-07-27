import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/listing_model.dart';

class ListingRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Create a new listing
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

  // Upload a photo and return its public URL
  Future<String> uploadPhoto(String listingId, Uint8List bytes, String fileName) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final path = '${user.id}/$listingId/$fileName';

    await _client.storage.from('listing-photos').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    return _client.storage.from('listing-photos').getPublicUrl(path);
  }

  // Save photo URL to listing_photos table
  Future<void> savePhotoRecord(String listingId, String photoUrl, bool isPrimary, int orderIndex) async {
    await _client.from('listing_photos').insert({
      'listing_id': listingId,
      'photo_url': photoUrl,
      'is_primary': isPrimary,
      'order_index': orderIndex,
    });
  }

  // Get all listings (for search)
 
  Future<List<ListingModel>> getListings({
    String? city,
    String? type,
    double? maxPrice,
  }) async {
  try {
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

    final response = await query.order('created_at', ascending: false);
    print('Listings response: ${response.length} items found');
    return (response as List)
        .map((json) => ListingModel.fromJson(json))
        .toList();
  } catch (e) {
    print('Error fetching listings: $e');
    rethrow;
  }
}

  // Get listings by current host
  Future<List<ListingModel>> getMyListings() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await _client
        .from('listings')
        .select('*, listing_photos(*)')
        .eq('host_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).map((json) => ListingModel.fromJson(json)).toList();
  }

  // Delete a listing
  Future<void> deleteListing(String listingId) async {
    await _client.from('listings').delete().eq('id', listingId);
  }

  // Toggle listing status
  Future<void> toggleListingStatus(String listingId, String status) async {
    await _client.from('listings').update({'status': status}).eq('id', listingId);
  }
}