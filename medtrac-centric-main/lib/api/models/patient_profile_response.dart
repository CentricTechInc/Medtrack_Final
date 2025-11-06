class PatientQuestion {
  final int id;
  final String question;
  final String answer;
  final int userId;

  PatientQuestion({
    required this.id,
    required this.question,
    required this.answer,
    required this.userId,
  });

  factory PatientQuestion.fromJson(Map<String, dynamic> json) {
    return PatientQuestion(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      userId: json['userId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'userId': userId,
    };
  }
}

class PatientProfileData {
  final String picture;
  final int id;
  final String email;
  final String name;
  final String phoneNumber;
  final String gender;
  final int age;
  final String weight;
  final String sleepQuality;
  final String mood;
  final int stressLevel;
  final List<String> mentalHealthGoal;
  final List <String>? medication;
  final List <String>? primaryConcern;
  final String? bloodGroup;
  final List<PatientQuestion> patientQuestions;

  PatientProfileData({
    required this.picture,
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.gender,
    required this.age,
    required this.weight,
    required this.sleepQuality,
    required this.mood,
    required this.stressLevel,
    required this.mentalHealthGoal,
    this.medication,
    this.primaryConcern,
    this.bloodGroup,
    required this.patientQuestions,
  });

  factory PatientProfileData.fromJson(Map<String, dynamic> json) {
    return PatientProfileData(
      picture: json['picture'] ?? '',
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] ?? 0,
      weight: json['weight'] ?? '',
      sleepQuality: json['sleep_quality'] ?? '',
      mood: json['mood'] ?? '',
      stressLevel: json['stress_level'] ?? 0,
      mentalHealthGoal: json['mental_health_goal'] is List
          ? List<String>.from(json['mental_health_goal'])
          : [],
      medication: json['medication'] is List
          ? List<String>.from(json['medication'])
          : [],
      primaryConcern: json['primary_concern'] is List
          ? List<String>.from(json['primary_concern'])
          : [],
      bloodGroup: json['blood_group'],
      patientQuestions: json['PatientQuestions'] is List
          ? (json['PatientQuestions'] as List)
              .map((q) => PatientQuestion.fromJson(q))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'picture': picture,
      'id': id,
      'email': email,
      'name': name,
      'phone_number': phoneNumber,
      'gender': gender,
      'age': age,
      'weight': weight,
      'sleep_quality': sleepQuality,
      'mood': mood,
      'stress_level': stressLevel,
      'mental_health_goal': mentalHealthGoal,
      'medication': medication,
      'primary_concern': primaryConcern,
      'blood_group': bloodGroup,
      'PatientQuestions': patientQuestions.map((q) => q.toJson()).toList(),
    };
  }
}

class PatientProfileResponse {
  final bool status;
  final String message;
  final PatientProfileData? data;

  PatientProfileResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory PatientProfileResponse.fromJson(Map<String, dynamic> json) {
    return PatientProfileResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? PatientProfileData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}
