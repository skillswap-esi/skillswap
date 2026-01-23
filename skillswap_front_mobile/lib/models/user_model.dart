/// User Model for SkillSwap
/// 
/// This model represents the user data from the backend service.
/// It maps to the UserDto from the backend.

class UserModel {
  final String? userId;
  final String email;
  final String? phoneNumber;
  final String fullName;
  final bool phoneVerified;
  final int creditsBalance;
  final double helperScore;
  final String? avatar;
  final List<String> roles;
  final List<String> fcmTokens;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.userId,
    required this.email,
    this.phoneNumber,
    required this.fullName,
    this.phoneVerified = false,
    this.creditsBalance = 0,
    this.helperScore = 0.0,
    this.avatar,
    this.roles = const ['USER'],
    this.fcmTokens = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Create a UserModel from JSON response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      fullName: json['fullName'] ?? '',
      phoneVerified: json['phoneVerified'] ?? false,
      creditsBalance: json['creditsBalance'] ?? 0,
      helperScore: (json['helperScore'] ?? 0).toDouble(),
      avatar: json['avatar'],
      roles: json['roles'] != null 
          ? List<String>.from(json['roles']) 
          : ['USER'],
      fcmTokens: json['fcmTokens'] != null 
          ? List<String>.from(json['fcmTokens']) 
          : [],
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'].toString()) 
          : null,
    );
  }

  /// Convert UserModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'phoneVerified': phoneVerified,
      'creditsBalance': creditsBalance,
      'helperScore': helperScore,
      'avatar': avatar,
      'roles': roles,
      'fcmTokens': fcmTokens,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? userId,
    String? email,
    String? phoneNumber,
    String? fullName,
    bool? phoneVerified,
    int? creditsBalance,
    double? helperScore,
    String? avatar,
    List<String>? roles,
    List<String>? fcmTokens,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      creditsBalance: creditsBalance ?? this.creditsBalance,
      helperScore: helperScore ?? this.helperScore,
      avatar: avatar ?? this.avatar,
      roles: roles ?? this.roles,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, email: $email, fullName: $fullName)';
  }
}

/// Request model for creating a new profile
class CreateProfileRequest {
  final String email;
  final String? phoneNumber;
  final String fullName;
  final String idToken;

  CreateProfileRequest({
    required this.email,
    this.phoneNumber,
    required this.fullName,
    required this.idToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'idToken': idToken,
    };
  }
}

/// Request model for updating a profile
class UpdateProfileRequest {
  final String? fullName;
  final String? phoneNumber;
  final String? avatar;

  UpdateProfileRequest({
    this.fullName,
    this.phoneNumber,
    this.avatar,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (fullName != null) json['fullName'] = fullName;
    if (phoneNumber != null) json['phoneNumber'] = phoneNumber;
    if (avatar != null) json['avatar'] = avatar;
    return json;
  }
}

/// Model for ledger/credit transactions
class LedgerTransaction {
  final String transactionId;
  final String? fromUserId;
  final String? toUserId;
  final int amount;
  final String? missionId;
  final DateTime timestamp;
  final String description;

  LedgerTransaction({
    required this.transactionId,
    this.fromUserId,
    this.toUserId,
    required this.amount,
    this.missionId,
    required this.timestamp,
    required this.description,
  });

  factory LedgerTransaction.fromJson(Map<String, dynamic> json) {
    return LedgerTransaction(
      transactionId: json['transactionId'] ?? '',
      fromUserId: json['fromUserId'],
      toUserId: json['toUserId'],
      amount: json['amount'] ?? 0,
      missionId: json['missionId'],
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'].toString()) 
          : DateTime.now(),
      description: json['description'] ?? '',
    );
  }
}
