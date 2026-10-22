class Technician {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final List<String>
  skills; // e.g. ['Plumbing', 'Fitting'], ['AC Service', 'Gas Refill']
  final double rating;
  final int totalJobs;
  final String
  locationArea; // e.g. 'Vishrambag, Sangli', 'Malkapur, Karad', 'Kupwad'
  final double latitude;
  final double longitude;
  final bool isOnline;
  final double todayEarnings;
  final int todayCompletedJobs;

  const Technician({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.skills,
    required this.rating,
    required this.totalJobs,
    required this.locationArea,
    required this.latitude,
    required this.longitude,
    this.isOnline = true,
    this.todayEarnings = 0.0,
    this.todayCompletedJobs = 0,
  });

  Technician copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    List<String>? skills,
    double? rating,
    int? totalJobs,
    String? locationArea,
    double? latitude,
    double? longitude,
    bool? isOnline,
    double? todayEarnings,
    int? todayCompletedJobs,
  }) {
    return Technician(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      skills: skills ?? this.skills,
      rating: rating ?? this.rating,
      totalJobs: totalJobs ?? this.totalJobs,
      locationArea: locationArea ?? this.locationArea,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOnline: isOnline ?? this.isOnline,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      todayCompletedJobs: todayCompletedJobs ?? this.todayCompletedJobs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'skills': skills,
      'rating': rating,
      'totalJobs': totalJobs,
      'locationArea': locationArea,
      'latitude': latitude,
      'longitude': longitude,
      'isOnline': isOnline,
      'todayEarnings': todayEarnings,
      'todayCompletedJobs': todayCompletedJobs,
    };
  }

  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalJobs: (json['totalJobs'] as num?)?.toInt() ?? 0,
      locationArea: json['locationArea'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 16.8524,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 74.5815,
      isOnline: json['isOnline'] as bool? ?? true,
      todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ?? 0.0,
      todayCompletedJobs: (json['todayCompletedJobs'] as num?)?.toInt() ?? 0,
    );
  }
}

class MockTechniciansData {
  static final List<Technician> initialTechnicians = [];
}
