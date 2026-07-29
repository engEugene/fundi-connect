import 'worker.dart';

enum BookingStatus { upcoming, completed, cancelled }

class Booking {
  const Booking({
    required this.id,
    required this.worker,
    required this.serviceType,
    required this.date,
    required this.time,
    required this.location,
    required this.status,
    this.serviceFee = 0,
    this.platformFee = 0,
    this.paymentMethod,
    this.isRated = false,
    this.clientName = 'Client',
    this.clientImageUrl = '',
    this.description = '',
    this.estimatedHours = 1,
  });

  final String id;
  final Worker worker;
  final String serviceType;
  final DateTime date;
  final String time;
  final String location;
  final BookingStatus status;
  final double serviceFee;
  final double platformFee;
  final String? paymentMethod;
  final bool isRated;
  final String clientName;
  final String clientImageUrl;
  final String description;
  final int estimatedHours;

  double get total => serviceFee + platformFee;

  static Booking? findById(String id) {
    try {
      return all.firstWhere((booking) => booking.id == id);
    } catch (_) {
      return null;
    }
  }

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
      serviceFee: 20000,
      platformFee: 1200,
      paymentMethod: 'Cash',
    ),
  ];
}
