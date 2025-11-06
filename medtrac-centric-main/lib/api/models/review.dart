class Review {
  final int id;
  final int doctorId;
  final int patientId;
  final String rating;
  final String description;
  final bool recommended;
  final String date;
  final String createdAt;
  final Patient patient;

  Review({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.rating,
    required this.description,
    required this.recommended,
    required this.date,
    required this.createdAt,
    required this.patient,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      doctorId: json['doctor_id'] ?? 0,
      patientId: json['patient_id'] ?? 0,
      rating: json['rating']?.toString() ?? '0',
      description: json['description'] ?? '',
      recommended: json['recommended'] ?? false,
      date: json['date'] ?? '',
      createdAt: json['createdAt'] ?? '',
      patient: Patient.fromJson(json['Patient'] ?? {}),
    );
  }

  double get ratingDouble => double.tryParse(rating) ?? 0.0;
}

class Patient {
  final int id;
  final String name;
  final String picture;

  Patient({
    required this.id,
    required this.name,
    required this.picture,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      picture: json['picture'] ?? '',
    );
  }
}

class RatingCount {
  final String rating;
  final String count;

  RatingCount({
    required this.rating,
    required this.count,
  });

  factory RatingCount.fromJson(Map<String, dynamic> json) {
    return RatingCount(
      rating: json['rating']?.toString() ?? '0',
      count: json['count']?.toString() ?? '0',
    );
  }

  double get ratingDouble => double.tryParse(rating) ?? 0.0;
  int get countInt => int.tryParse(count) ?? 0;
}

class ReviewsResponse {
  final bool status;
  final String message;
  final ReviewsData data;

  ReviewsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) {
    return ReviewsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: ReviewsData.fromJson(json['data'] ?? {}),
    );
  }
}

class ReviewsData {
  final int count;
  final List<Review> rows;
  final String averageRating;
  final List<RatingCount> ratingCount;

  ReviewsData({
    required this.count,
    required this.rows,
    required this.averageRating,
    required this.ratingCount,
  });

  factory ReviewsData.fromJson(Map<String, dynamic> json) {
    return ReviewsData(
      count: json['count'] ?? 0,
      rows: (json['rows'] as List<dynamic>?)
              ?.map((item) => Review.fromJson(item))
              .toList() ??
          [],
      averageRating: json['average_rating']?.toString() ?? '0',
      ratingCount: (json['rating_count'] as List<dynamic>?)
              ?.map((item) => RatingCount.fromJson(item))
              .toList() ??
          [],
    );
  }

  double get averageRatingDouble => double.tryParse(averageRating) ?? 0.0;
}
