class BannerResponse {
  final bool status;
  final String message;
  final List<BannerItem>? data;

  BannerResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? (json['data'] as List).map((e) => BannerItem.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class BannerItem {
  final int id;
  final String title;
  final String file;
  final bool visibility;

  BannerItem({
    required this.id,
    required this.title,
    required this.file,
    required this.visibility,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      file: json['file'] ?? '',
      visibility: json['visibility'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'file': file,
      'visibility': visibility,
    };
  }
}