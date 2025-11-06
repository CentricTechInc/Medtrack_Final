class UserMedicalHistory {
  final String bloodGroup;
  final String weight;
  final List<String> primaryConcerns;
  final List<String> medications;

  UserMedicalHistory({
    required this.bloodGroup,
    required this.weight,
    required this.primaryConcerns,
    required this.medications,
  });

  factory UserMedicalHistory.fromJson(Map<String, dynamic> json) {
    return UserMedicalHistory(
      bloodGroup: json['blood_group'] ?? '',
      weight: json['weight'] ?? '',
      primaryConcerns: _parseStringListField(json['primary_concerns'] ?? json['primary_concern']),
      medications: _parseStringListField(json['medications'] ?? json['medication']),
    );
  }

  static List<String> _parseStringListField(dynamic field) {
    if (field == null) return [];
    if (field is List) {
      return List<String>.from(field);
    }
    if (field is String && field.isNotEmpty) {
      return field.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'blood_group': bloodGroup,
      'weight': weight,
      'primary_concerns': primaryConcerns,
      'medications': medications,
    };
  }

  // Convert to string format for API
  String get primaryConcernsString => primaryConcerns.join(',');
  String get medicationsString => medications.join(',');
}
