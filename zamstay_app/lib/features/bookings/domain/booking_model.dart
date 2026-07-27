class BookingModel {
  final String id;
  final String listingId;
  final String guestId;
  final String hostId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int totalNights;
  final double totalPrice;
  final String status;
  final String? guestMessage;
  final DateTime createdAt;

  // Optional joined fields
  final String? listingTitle;
  final String? listingCity;
  final String? listingPhotoUrl;
  final String? guestName;
  final String? guestEmail;

  BookingModel({
    required this.id,
    required this.listingId,
    required this.guestId,
    required this.hostId,
    required this.checkIn,
    required this.checkOut,
    required this.totalNights,
    required this.totalPrice,
    required this.status,
    this.guestMessage,
    required this.createdAt,
    this.listingTitle,
    this.listingCity,
    this.listingPhotoUrl,
    this.guestName,
    this.guestEmail,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final listing = json['listings'] as Map<String, dynamic>?;
    final guest = json['guest'] as Map<String, dynamic>?;
    final photos = listing?['listing_photos'] as List<dynamic>?;

    return BookingModel(
      id: json['id'],
      listingId: json['listing_id'],
      guestId: json['guest_id'],
      hostId: json['host_id'],
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      totalNights: json['total_nights'] ?? 0,
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'],
      guestMessage: json['guest_message'],
      createdAt: DateTime.parse(json['created_at']),
      listingTitle: listing?['title'],
      listingCity: listing?['city'],
      listingPhotoUrl: photos != null && photos.isNotEmpty
          ? photos.first['photo_url']
          : null,
      guestName: guest?['full_name'],
      guestEmail: guest?['email'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
}