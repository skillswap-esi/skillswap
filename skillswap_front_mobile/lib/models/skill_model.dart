/// Skill Model for SkillSwap
/// 
/// This model represents skill data from the backend skill service.

class SkillModel {
  final String? skillId;
  final String? ownerId;
  final String title;
  final String description;
  final SkillCategory category;
  final double latitude;
  final double longitude;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? distance; // Distance in km (for search results)
  
  // Owner information (enriched from User service)
  final String? ownerName;
  final double? ownerScore;
  final String? ownerAvatar;

  SkillModel({
    this.skillId,
    this.ownerId,
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.active = true,
    this.createdAt,
    this.updatedAt,
    this.distance,
    this.ownerName,
    this.ownerScore,
    this.ownerAvatar,
  });

  /// Create a SkillModel from JSON response
  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      skillId: json['skillId'],
      ownerId: json['ownerId'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: SkillCategory.fromString(json['category'] ?? 'AUTRE'),
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      active: json['active'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'].toString()) 
          : null,
      distance: json['distance'] != null 
          ? (json['distance'] as num).toDouble() 
          : null,
      ownerName: json['ownerName'],
      ownerScore: json['ownerScore'] != null 
          ? (json['ownerScore'] as num).toDouble() 
          : null,
      ownerAvatar: json['ownerAvatar'],
    );
  }

  /// Convert SkillModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      if (skillId != null) 'skillId': skillId,
      if (ownerId != null) 'ownerId': ownerId,
      'title': title,
      'description': description,
      'category': category.value,
      'latitude': latitude,
      'longitude': longitude,
      'active': active,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (distance != null) 'distance': distance,
      if (ownerName != null) 'ownerName': ownerName,
      if (ownerScore != null) 'ownerScore': ownerScore,
      if (ownerAvatar != null) 'ownerAvatar': ownerAvatar,
    };
  }

  /// Create a copy of SkillModel with updated fields
  SkillModel copyWith({
    String? skillId,
    String? ownerId,
    String? title,
    String? description,
    SkillCategory? category,
    double? latitude,
    double? longitude,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? distance,
    String? ownerName,
    double? ownerScore,
    String? ownerAvatar,
  }) {
    return SkillModel(
      skillId: skillId ?? this.skillId,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      distance: distance ?? this.distance,
      ownerName: ownerName ?? this.ownerName,
      ownerScore: ownerScore ?? this.ownerScore,
      ownerAvatar: ownerAvatar ?? this.ownerAvatar,
    );
  }

  @override
  String toString() {
    return 'SkillModel(skillId: $skillId, title: $title, category: ${category.label})';
  }
}

/// Skill categories matching backend enum
enum SkillCategory {
  bricolage('BRICOLAGE', 'Bricolage', '🔨'),
  scolaire('SCOLAIRE', 'Scolaire', '📚'),
  sport('SPORT', 'Sport', '⚽'),
  informatique('INFORMATIQUE', 'Informatique', '💻'),
  cuisine('CUISINE', 'Cuisine', '🍳'),
  jardinage('JARDINAGE', 'Jardinage', '🌱'),
  musique('MUSIQUE', 'Musique', '🎵'),
  langues('LANGUES', 'Langues', '🗣️'),
  art('ART', 'Art', '🎨'),
  autre('AUTRE', 'Autre', '📦');

  final String value;
  final String label;
  final String emoji;

  const SkillCategory(this.value, this.label, this.emoji);

  static SkillCategory fromString(String value) {
    return SkillCategory.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => SkillCategory.autre,
    );
  }

  @override
  String toString() => value;
}

/// Request model for creating a new skill
class CreateSkillRequest {
  final String title;
  final String description;
  final String category;
  final double latitude;
  final double longitude;

  CreateSkillRequest({
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// Request model for updating a skill
class UpdateSkillRequest {
  final String? title;
  final String? description;
  final String? category;
  final double? latitude;
  final double? longitude;
  final bool? active;

  UpdateSkillRequest({
    this.title,
    this.description,
    this.category,
    this.latitude,
    this.longitude,
    this.active,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (category != null) json['category'] = category;
    if (latitude != null) json['latitude'] = latitude;
    if (longitude != null) json['longitude'] = longitude;
    if (active != null) json['active'] = active;
    return json;
  }
}
