class ListingModel {
  final String id;
  final String hostId;
  final String title;
  final String description;
  final String type;
  final String city;
  final String address;
  final double? latitude;
  final double? longitude;
  final double pricePerNight;
  final int rooms;
  final List<String> amenities;
  final String status;
  final List<String> photoUrls;
  final DateTime createdAt;

  ListingModel({
    required this.id,
    required this.hostId,
    required this.title,
    required this.description,
    required this.type,
    required this.city,
    required this.address,
    this.latitude,
    this.longitude,
    required this.pricePerNight,
    required this.rooms,
    required this.amenities,
    required this.status,
    required this.photoUrls,
    required this.createdAt,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'],
      hostId: json['host_id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      city: json['city'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      pricePerNight: double.parse(json['price_per_night'].toString()),
      rooms: json['rooms'],
      amenities: List<String>.from(json['amenities'] ?? []),
      status: json['status'],
      photoUrls: (json['listing_photos'] as List<dynamic>?)
              ?.map((p) => p['photo_url'] as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}