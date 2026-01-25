import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String messageId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool read;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.read,
  });

  factory ChatMessage.fromFirestore(Map<String, dynamic> data) {
    return ChatMessage(
      messageId: data['messageId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Unknown',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'read': read,
    };
  }
}

class ChatThread {
  final String threadId;
  final List<String> participants;
  final String skillId;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String? lastMessage;

  ChatThread({
    required this.threadId,
    required this.participants,
    required this.skillId,
    required this.createdAt,
    required this.lastMessageAt,
    this.lastMessage,
  });

  factory ChatThread.fromFirestore(Map<String, dynamic> data) {
    return ChatThread(
      threadId: data['threadId'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      skillId: data['skillId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessage: data['lastMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'threadId': threadId,
      'participants': participants,
      'skillId': skillId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'lastMessage': lastMessage,
    };
  }
}

class MeetingPoint {
  final double lat;
  final double lng;
  final String? partnerPlaceId;
  final String? placeName;
  final String? placeAddress;

  MeetingPoint({
    required this.lat,
    required this.lng,
    this.partnerPlaceId,
    this.placeName,
    this.placeAddress,
  });

  factory MeetingPoint.fromJson(Map<String, dynamic> json) {
    return MeetingPoint(
      lat: json['lat']?.toDouble() ?? 0.0,
      lng: json['lng']?.toDouble() ?? 0.0,
      partnerPlaceId: json['partnerPlaceId'],
      placeName: json['placeName'],
      placeAddress: json['placeAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      if (partnerPlaceId != null) 'partnerPlaceId': partnerPlaceId,
      if (placeName != null) 'placeName': placeName,
      if (placeAddress != null) 'placeAddress': placeAddress,
    };
  }
}
