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
    this.about,
    this.jobsDone,
    this.yearsExp,
    this.district,
    this.pastWorkUrls = const [],
  });

  factory Worker.fromJson(String id, Map<String, dynamic> json) {
    final category = json['category'] as String? ?? 'General';
    return Worker(
      id: id,
      name: json['displayName'] as String? ?? 'Tradesman',
      role: category,
      category: category,
      imageUrl: json['photoUrl'] as String? ?? '',
      rating: (json['ratingAvg'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      isOpen: json['isOpen'] as bool? ?? false,
      about: json['bio'] as String?,
      jobsDone: json['jobsDone'] as int?,
      yearsExp: json['yearsExp'] as int?,
      district: json['district'] as String?,
      pastWorkUrls: (json['portfolioUrls'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

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
  final String? about;
  final int? jobsDone;
  final int? yearsExp;
  final String? district;
  final List<String> pastWorkUrls;

  Map<String, dynamic> toJson() => {
        'uid': id,
        'displayName': name,
        'category': category,
        'photoUrl': imageUrl,
        'ratingAvg': rating,
        'reviewCount': reviewCount,
        'hourlyRate': hourlyRate,
        'isVerified': isVerified,
        'isOpen': isOpen,
        'bio': about,
        'jobsDone': jobsDone,
        'yearsExp': yearsExp,
        'district': district,
        'portfolioUrls': pastWorkUrls,
      };

  static Worker? findById(String id) {
    final all = <Worker>[...nearby, ...discover];
    try {
      return all.firstWhere((worker) => worker.id == id);
    } catch (_) {
      return null;
    }
  }

  static const List<Worker> discover = [
    Worker(
      id: 'd1',
      name: 'Jean Pierre Habimana',
      role: 'Electrician',
      category: 'Electrician',
      imageUrl: 'https://i.pravatar.cc/300?img=11',
      rating: 4.9,
      reviewCount: 56,
      distanceKm: 0.8,
      hourlyRate: 6000,
      isVerified: true,
      isOpen: true,
      about:
          'Licensed electrician with 6+ years of experience in residential and commercial wiring, solar installation, and electrical repairs across Kigali.',
      jobsDone: 127,
      yearsExp: 6,
      pastWorkUrls: [
        'https://i.pravatar.cc/300?img=15',
        'https://i.pravatar.cc/300?img=16',
        'https://i.pravatar.cc/300?img=17',
      ],
    ),
    Worker(
      id: 'd2',
      name: 'Emmanuel Nkurunziza',
      role: 'Electrician',
      category: 'Electrician',
      imageUrl: 'https://i.pravatar.cc/300?img=13',
      rating: 4.7,
      reviewCount: 41,
      distanceKm: 1.2,
      hourlyRate: 5500,
      isVerified: true,
      isOpen: true,
      about:
          'Skilled electrician specializing in home wiring, appliance installation, and fault finding.',
      jobsDone: 98,
      yearsExp: 5,
      pastWorkUrls: [
        'https://i.pravatar.cc/300?img=18',
        'https://i.pravatar.cc/300?img=19',
      ],
    ),
    Worker(
      id: 'd3',
      name: 'Claudine Mukamana',
      role: 'Electrician',
      category: 'Electrician',
      imageUrl: 'https://i.pravatar.cc/300?img=5',
      rating: 4.5,
      reviewCount: 29,
      distanceKm: 2.1,
      hourlyRate: 4800,
      isVerified: false,
      isOpen: false,
      about:
          'Detail-oriented electrician with a focus on safety and clean installations.',
      jobsDone: 64,
      yearsExp: 4,
      pastWorkUrls: [
        'https://i.pravatar.cc/300?img=20',
        'https://i.pravatar.cc/300?img=21',
      ],
    ),
    Worker(
      id: 'd4',
      name: 'Patrick Nsabimana',
      role: 'Electrician',
      category: 'Electrician',
      imageUrl: 'https://i.pravatar.cc/300?img=14',
      rating: 4.3,
      reviewCount: 17,
      distanceKm: 3.0,
      hourlyRate: 4000,
      isVerified: true,
      isOpen: true,
      about:
          'Affordable electrician offering reliable repairs and maintenance for homes and small businesses.',
      jobsDone: 45,
      yearsExp: 3,
      pastWorkUrls: [
        'https://i.pravatar.cc/300?img=22',
        'https://i.pravatar.cc/300?img=23',
      ],
    ),
  ];

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
      about:
          'Licensed electrician with 6+ years of experience in residential and commercial wiring, solar installation, and electrical repairs across Kigali.',
      jobsDone: 127,
      yearsExp: 6,
      pastWorkUrls: [
        'https://i.pravatar.cc/300?img=15',
        'https://i.pravatar.cc/300?img=16',
        'https://i.pravatar.cc/300?img=17',
      ],
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
      about:
          'Professional cleaner providing thorough home and office cleaning services.',
      jobsDone: 82,
      yearsExp: 4,
      pastWorkUrls: [
        'https://i.pravatar.cc/300?img=24',
        'https://i.pravatar.cc/300?img=25',
      ],
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
      about:
          'Experienced plumber handling pipe repairs, installations, and drainage solutions.',
      jobsDone: 110,
      yearsExp: 5,
      pastWorkUrls: [
        'https://i.pravatar.cc/300?img=26',
        'https://i.pravatar.cc/300?img=27',
      ],
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
      about:
          'Carpenter crafting custom furniture, cabinets, and wood repairs.',
      jobsDone: 37,
      yearsExp: 3,
      pastWorkUrls: [
        'https://i.pravatar.cc/300?img=28',
        'https://i.pravatar.cc/300?img=29',
      ],
    ),
  ];
}
