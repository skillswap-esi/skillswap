enum MissionStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
  rejected;

  String get value {
    switch (this) {
      case MissionStatus.pending:
        return 'PENDING';
      case MissionStatus.accepted:
        return 'ACCEPTED';
      case MissionStatus.inProgress:
        return 'IN_PROGRESS';
      case MissionStatus.completed:
        return 'COMPLETED';
      case MissionStatus.cancelled:
        return 'CANCELLED';
      case MissionStatus.rejected:
        return 'REJECTED';
    }
  }

  static MissionStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return MissionStatus.pending;
      case 'ACCEPTED':
        return MissionStatus.accepted;
      case 'IN_PROGRESS':
        return MissionStatus.inProgress;
      case 'COMPLETED':
        return MissionStatus.completed;
      case 'CANCELLED':
        return MissionStatus.cancelled;
      case 'REJECTED':
        return MissionStatus.rejected;
      default:
        return MissionStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case MissionStatus.pending:
        return 'Pending';
      case MissionStatus.accepted:
        return 'Accepted';
      case MissionStatus.inProgress:
        return 'In Progress';
      case MissionStatus.completed:
        return 'Completed';
      case MissionStatus.cancelled:
        return 'Cancelled';
      case MissionStatus.rejected:
        return 'Rejected';
    }
  }
}

class MissionModel {
  final String missionId;
  final String skillId;
  final String? skillTitle;
  final String? skillCategory;
  final String requesterId;
  final String? requesterName;
  final String? requesterAvatar;
  final String? helperId;
  final String? helperName;
  final String? helperAvatar;
  final int? helperScore;
  final String title;
  final String description;
  final MissionStatus status;
  final DateTime scheduledDate;
  final int duration;
  final int creditCost;
  final double? latitude;
  final double? longitude;
  final String? location;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? rejectionReason;

  MissionModel({
    required this.missionId,
    required this.skillId,
    this.skillTitle,
    this.skillCategory,
    required this.requesterId,
    this.requesterName,
    this.requesterAvatar,
    this.helperId,
    this.helperName,
    this.helperAvatar,
    this.helperScore,
    required this.title,
    required this.description,
    required this.status,
    required this.scheduledDate,
    required this.duration,
    required this.creditCost,
    this.latitude,
    this.longitude,
    this.location,
    required this.createdAt,
    this.updatedAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.rejectionReason,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      missionId: json['missionId'],
      skillId: json['skillId'],
      skillTitle: json['skillTitle'],
      skillCategory: json['skillCategory'],
      requesterId: json['requesterId'],
      requesterName: json['requesterName'],
      requesterAvatar: json['requesterAvatar'],
      helperId: json['helperId'],
      helperName: json['helperName'],
      helperAvatar: json['helperAvatar'],
      helperScore: json['helperScore'],
      title: json['title'],
      description: json['description'],
      status: MissionStatus.fromString(json['status']),
      scheduledDate: DateTime.parse(json['scheduledDate']),
      duration: json['duration'],
      creditCost: json['creditCost'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      location: json['location'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt']) : null,
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
      cancellationReason: json['cancellationReason'],
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'missionId': missionId,
      'skillId': skillId,
      'skillTitle': skillTitle,
      'skillCategory': skillCategory,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterAvatar': requesterAvatar,
      'helperId': helperId,
      'helperName': helperName,
      'helperAvatar': helperAvatar,
      'helperScore': helperScore,
      'title': title,
      'description': description,
      'status': status.value,
      'scheduledDate': scheduledDate.toIso8601String(),
      'duration': duration,
      'creditCost': creditCost,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'rejectionReason': rejectionReason,
    };
  }
}

class CreateMissionRequest {
  final String skillId;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final int duration;
  final int creditCost;

  CreateMissionRequest({
    required this.skillId,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.duration,
    required this.creditCost,
  });

  Map<String, dynamic> toJson() {
    return {
      'skillId': skillId,
      'title': title,
      'description': description,
      'scheduledDate': scheduledDate.toIso8601String(),
      'duration': duration,
      'creditCost': creditCost,
    };
  }
}
