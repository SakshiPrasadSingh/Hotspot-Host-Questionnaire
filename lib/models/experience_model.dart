// lib/models/experience_model.dart

class Experience {
  final int id;
  final String name;
  final String tagline;
  final String description;
  final String imageUrl;
  final String iconUrl;

  Experience({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.imageUrl,
    required this.iconUrl,
  });

  // Factory method to create Experience from JSON
  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      tagline: json['tagline'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      iconUrl: json['icon_url'] ?? '',
    );
  }

  // Method to convert Experience to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'description': description,
      'image_url': imageUrl,
      'icon_url': iconUrl,
    };
  }

  // CopyWith method for immutability
  Experience copyWith({
    int? id,
    String? name,
    String? tagline,
    String? description,
    String? imageUrl,
    String? iconUrl,
  }) {
    return Experience(
      id: id ?? this.id,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      iconUrl: iconUrl ?? this.iconUrl,
    );
  }
}

// API Response Model
class ExperienceResponse {
  final String message;
  final List<Experience> experiences;

  ExperienceResponse({
    required this.message,
    required this.experiences,
  });

  factory ExperienceResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final experiencesJson = data['experiences'] as List<dynamic>? ?? [];

    return ExperienceResponse(
      message: json['message'] ?? '',
      experiences: experiencesJson
          .map((exp) => Experience.fromJson(exp as Map<String, dynamic>))
          .toList(),
    );
  }
}