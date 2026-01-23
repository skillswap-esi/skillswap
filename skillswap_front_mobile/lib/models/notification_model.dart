enum NotificationType {
  missionCreated,
  missionAccepted,
  missionRejected,
  missionStarted,
  missionCompleted,
  missionCancelled,
  skillCreated,
  creditReceived,
  creditSpent;

  String get value {
    switch (this) {
      case NotificationType.missionCreated:
        return 'MISSION_CREATED';
      case NotificationType.missionAccepted:
        return 'MISSION_ACCEPTED';
      case NotificationType.missionRejected:
        return 'MISSION_REJECTED';
      case NotificationType.missionStarted:
        return 'MISSION_STARTED';
      case NotificationType.missionCompleted:
        return 'MISSION_COMPLETED';
      case NotificationType.missionCancelled:
        return 'MISSION_CANCELLED';
      case NotificationType.skillCreated:
        return 'SKILL_CREATED';
      case NotificationType.creditReceived:
        return 'CREDIT_RECEIVED';
      case NotificationType.creditSpent:
        return 'CREDIT_SPENT';
    }
  }

  static NotificationType fromString(String type) {
    switch (type.toUpperCase()) {
      case 'MISSION_CREATED':
        return NotificationType.missionCreated;
      case 'MISSION_ACCEPTED':
        return NotificationType.missionAccepted;
      case 'MISSION_REJECTED':
        return NotificationType.missionRejected;
      case 'MISSION_STARTED':
        return NotificationType.missionStarted;
      case 'MISSION_COMPLETED':
        return NotificationType.missionCompleted;
      case 'MISSION_CANCELLED':
        return NotificationType.missionCancelled;
      case 'SKILL_CREATED':
        return NotificationType.skillCreated;
      case 'CREDIT_RECEIVED':
        return NotificationType.creditReceived;
      case 'CREDIT_SPENT':
        return NotificationType.creditSpent;
      default:
        return NotificationType.missionCreated;
    }
  }
}

class NotificationModel {
  final String notificationId;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool read;
  final DateTime sentAt;
  final DateTime? readAt;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.read,
    required this.sentAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'],
      userId: json['userId'],
      type: NotificationType.fromString(json['type']),
      title: json['title'],
      message: json['message'],
      data: json['data'] as Map<String, dynamic>?,
      read: json['read'],
      sentAt: DateTime.parse(json['sentAt']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'type': type.value,
      'title': title,
      'message': message,
      'data': data,
      'read': read,
      'sentAt': sentAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }
}
