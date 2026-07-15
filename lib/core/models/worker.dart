// dummy data for ui
class Worker {
  const Worker({
    required this.id,
    required this.name,
    required this.role,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.hourlyRate,
    this.isVerified = false,
    this.isOpen = false,
  });

  final String id;
  final String name;
  final String role;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final double hourlyRate;
  final bool isVerified;
  final bool isOpen;

  static const List<Worker> nearby = [
    Worker(
      id: '1',
      name: 'Jean Pierre Habimana',
      role: 'Electrician',
      category: 'Electrician',
      imageUrl: 'https://i.pravatar.cc/300?img=11',
      rating: 4.9,
      reviewCount: 18,
      distanceKm: 0.8,
      hourlyRate: 6000,
      isVerified: true,
      isOpen: true,
    ),
    Worker(
      id: '2',
      name: 'Marie Claire Uwase',
      role: 'Cleaner',
      category: 'Cleaner',
      imageUrl: 'https://i.pravatar.cc/300?img=5',
      rating: 4.7,
      reviewCount: 14,
      distanceKm: 1.4,
      hourlyRate: 3500,
      isVerified: true,
      isOpen: true,
    ),
    Worker(
      id: '3',
      name: 'Patrick Ndayisaba',
      role: 'Plumber',
      category: 'Plumber',
      imageUrl: 'https://i.pravatar.cc/300?img=3',
      rating: 4.8,
      reviewCount: 22,
      distanceKm: 2.1,
      hourlyRate: 5000,
      isVerified: true,
      isOpen: false,
    ),
    Worker(
      id: '4',
      name: 'Diane Mukamana',
      role: 'Carpenter',
      category: 'Carpenter',
      imageUrl: 'https://i.pravatar.cc/300?img=9',
      rating: 4.6,
      reviewCount: 10,
      distanceKm: 3.0,
      hourlyRate: 4500,
      isVerified: false,
      isOpen: true,
    ),
  ];
}
