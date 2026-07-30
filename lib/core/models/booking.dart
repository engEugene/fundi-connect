import 'package:cloud_firestore/cloud_firestore.dart';

import 'worker.dart';

/// The bucket the Bookings tabs group by. The Firestore document stores a
/// finer-grained lifecycle string ([Booking.statusRaw]); [BookingStatus] is the
/// coarse view the UI renders.
enum BookingStatus { upcoming, completed, cancelled }

/// Firestore lifecycle values for `bookings/{id}.status`.
class BookingLifecycle {
  BookingLifecycle._();

  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String rejected = 'rejected';

  /// Maps a stored lifecycle string to the coarse tab bucket.
  static BookingStatus toStatus(String raw) {
    switch (raw) {
      case completed:
        return BookingStatus.completed;
      case cancelled:
      case rejected:
        return BookingStatus.cancelled;
      default:
        // pending / accepted / in_progress all read as "Upcoming".
        return BookingStatus.upcoming;
    }
  }
}

class Booking {
  const Booking({
    required this.id,
    required this.worker,
    required this.serviceType,
    required this.date,
    required this.time,
    required this.location,
    required this.status,
    this.statusRaw = BookingLifecycle.pending,
    this.serviceFee = 0,
    this.platformFee = 0,
    this.paymentMethod,
    this.isRated = false,
    this.clientId = '',
    this.clientName = 'Client',
    this.clientImageUrl = '',
    this.description = '',
    this.estimatedHours = 1,
    this.createdAt,
  });

  final String id;
  final Worker worker;
  final String serviceType;
  final DateTime date;
  final String time;
  final String location;
  final BookingStatus status;

  /// Full Firestore lifecycle value (`pending`, `accepted`, `in_progress`,
  /// `completed`, `cancelled`, `rejected`). [status] is derived from this.
  final String statusRaw;

  final double serviceFee;
  final double platformFee;
  final String? paymentMethod;
  final bool isRated;
  final String clientId;
  final String clientName;
  final String clientImageUrl;
  final String description;
  final int estimatedHours;
  final DateTime? createdAt;

  String get workerId => worker.id;

  double get total => serviceFee + platformFee;

  /// Builds a booking from a Firestore document.
  ///
  /// Worker display fields are denormalized onto the booking document so the
  /// bookings list renders without a second read per row.
  factory Booking.fromJson(String id, Map<String, dynamic> json) {
    DateTime? toDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    final scheduledAt = toDate(json['scheduledAt']) ?? DateTime.now();
    final raw = json['status'] as String? ?? BookingLifecycle.pending;

    final worker = Worker(
      id: json['workerId'] as String? ?? '',
      name: json['workerName'] as String? ?? 'Tradesman',
      role: json['workerRole'] as String? ?? '',
      category: json['workerRole'] as String? ?? '',
      imageUrl: json['workerImageUrl'] as String? ?? '',
      rating: (json['workerRating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['workerReviewCount'] as int? ?? 0,
      distanceKm: 0,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0,
    );

    return Booking(
      id: id,
      worker: worker,
      serviceType: json['serviceType'] as String? ?? '',
      date: scheduledAt,
      time: json['timeLabel'] as String? ?? '',
      location: json['location'] as String? ?? '',
      status: BookingLifecycle.toStatus(raw),
      statusRaw: raw,
      serviceFee: (json['serviceFee'] as num?)?.toDouble() ?? 0,
      platformFee: (json['platformFee'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['paymentMethod'] as String?,
      isRated: json['isRated'] as bool? ?? false,
      clientId: json['clientId'] as String? ?? '',
      clientName: json['clientName'] as String? ?? 'Client',
      clientImageUrl: json['clientImageUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      estimatedHours: json['estimatedHours'] as int? ?? 1,
      createdAt: toDate(json['createdAt']),
    );
  }

  /// Serializes for a Firestore write. Server-managed fields (`createdAt`,
  /// `updatedAt`) are set by the repository, not here.
  Map<String, dynamic> toJson() => {
        'clientId': clientId,
        'clientName': clientName,
        'clientImageUrl': clientImageUrl,
        'workerId': worker.id,
        'workerName': worker.name,
        'workerRole': worker.role,
        'workerImageUrl': worker.imageUrl,
        'workerRating': worker.rating,
        'workerReviewCount': worker.reviewCount,
        'hourlyRate': worker.hourlyRate,
        'serviceType': serviceType,
        'description': description,
        'location': location,
        'scheduledAt': Timestamp.fromDate(date),
        'timeLabel': time,
        'estimatedHours': estimatedHours,
        'serviceFee': serviceFee,
        'platformFee': platformFee,
        'totalAmount': total,
        'paymentMethod': paymentMethod,
        'status': statusRaw,
        'isRated': isRated,
      };

  Booking copyWith({
    BookingStatus? status,
    String? statusRaw,
    bool? isRated,
  }) {
    return Booking(
      id: id,
      worker: worker,
      serviceType: serviceType,
      date: date,
      time: time,
      location: location,
      status: status ?? this.status,
      statusRaw: statusRaw ?? this.statusRaw,
      serviceFee: serviceFee,
      platformFee: platformFee,
      paymentMethod: paymentMethod,
      isRated: isRated ?? this.isRated,
      clientId: clientId,
      clientName: clientName,
      clientImageUrl: clientImageUrl,
      description: description,
      estimatedHours: estimatedHours,
      createdAt: createdAt,
    );
  }

  static Booking? findById(String id) {
    try {
      return all.firstWhere((booking) => booking.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Sample data kept for widgets that still render mock bookings (e.g. before
  /// a signed-in client has any real bookings). Firestore is the source of
  /// truth once the client is authenticated.
  static final List<Booking> all = [
    Booking(
      id: 'b1',
      worker: Worker.nearby[0], // Jean Pierre Habimana
      serviceType: 'Electrical Wiring',
      date: DateTime(2025, 7, 15),
      time: '10:00 AM',
      location: 'KG 14 Ave, Kacyiru, Kigali',
      status: BookingStatus.upcoming,
      serviceFee: 12000,
      platformFee: 800,
      paymentMethod: 'MTN MoMo',
    ),
    Booking(
      id: 'b2',
      worker: Worker.nearby[2], // Patrick Ndayisaba
      serviceType: 'Pipe Repair',
      date: DateTime(2025, 7, 17),
      time: '2:00 PM',
      location: 'KN 3 Rd, Nyarugenge, Kigali',
      status: BookingStatus.upcoming,
      serviceFee: 8500,
      platformFee: 500,
      paymentMethod: 'Airtel Money',
    ),
    Booking(
      id: 'b3',
      worker: Worker.nearby[1], // Marie Claire Uwase
      serviceType: 'Home Cleaning',
      date: DateTime(2025, 7, 7),
      time: '9:00 AM',
      location: 'KK 15 St, Kimihurura, Kigali',
      status: BookingStatus.completed,
      statusRaw: BookingLifecycle.completed,
      serviceFee: 15000,
      platformFee: 1000,
      paymentMethod: 'MTN MoMo',
      isRated: false,
    ),
    Booking(
      id: 'b4',
      worker: Worker.nearby[3], // Diane Mukamana
      serviceType: 'Furniture Repair',
      date: DateTime(2025, 7, 10),
      time: '11:30 AM',
      location: 'KG 7 Ave, Remera, Kigali',
      status: BookingStatus.cancelled,
      statusRaw: BookingLifecycle.cancelled,
      serviceFee: 20000,
      platformFee: 1200,
      paymentMethod: 'Cash',
    ),
  ];
}
