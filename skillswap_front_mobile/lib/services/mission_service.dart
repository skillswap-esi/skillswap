import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/mission_model.dart';

class MissionService {
  static final MissionService _instance = MissionService._internal();
  factory MissionService() => _instance;
  MissionService._internal();

  final http.Client _client = http.Client();

  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Map<String, String> _authHeaders(String authToken) => {
        ..._jsonHeaders,
        'Authorization': 'Bearer $authToken',
      };

  String get _baseUrl => '${ApiConfig.baseUrl}/missions';

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      String message = 'Unknown error';
      try {
        final body = json.decode(response.body);
        message = body['message'] ?? body['error'] ?? 'Unknown error';
      } catch (_) {
        message = response.body.isNotEmpty ? response.body : 'Unknown error';
      }
      throw MissionServiceException(
        statusCode: response.statusCode,
        message: message,
      );
    }
  }

  Future<T> _safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on SocketException {
      throw MissionServiceException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } on HttpException catch (e) {
      throw MissionServiceException(
        statusCode: 0,
        message: 'HTTP Error: ${e.message}',
      );
    } on FormatException {
      throw MissionServiceException(
        statusCode: 0,
        message: 'Invalid response format',
      );
    }
  }

  // Create Mission
  Future<MissionModel> createMission({
    required CreateMissionRequest request,
    required String authToken,
  }) async {
    return _safeApiCall(() async {
      final response = await _client.post(
        Uri.parse(_baseUrl),
        headers: _authHeaders(authToken),
        body: json.encode(request.toJson()),
      );

      final data = _handleResponse(response);
      return MissionModel.fromJson(data);
    });
  }

  // Get Mission by ID
  Future<MissionModel> getMissionById(String missionId, String authToken) async {
    return _safeApiCall(() async {
      final response = await _client.get(
        Uri.parse('$_baseUrl/$missionId'),
        headers: _authHeaders(authToken),
      );

      final data = _handleResponse(response);
      return MissionModel.fromJson(data);
    });
  }

  // Get User Missions
  Future<List<MissionModel>> getUserMissions({
    required String userId,
    required String authToken,
    String? role, // REQUESTER or HELPER
    String? status,
  }) async {
    return _safeApiCall(() async {
      final queryParams = <String, String>{};
      if (role != null) queryParams['role'] = role;
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$_baseUrl/user/$userId')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      final response = await _client.get(
        uri,
        headers: _authHeaders(authToken),
      );

      final data = _handleResponse(response) as List;
      return data.map((e) => MissionModel.fromJson(e)).toList();
    });
  }

  // Accept Mission
  Future<MissionModel> acceptMission(String missionId, String authToken) async {
    return _safeApiCall(() async {
      final response = await _client.post(
        Uri.parse('$_baseUrl/$missionId/accept'),
        headers: _authHeaders(authToken),
      );

      final data = _handleResponse(response);
      return MissionModel.fromJson(data);
    });
  }

  // Reject Mission
  Future<void> rejectMission({
    required String missionId,
    required String reason,
    required String authToken,
  }) async {
    return _safeApiCall(() async {
      final response = await _client.post(
        Uri.parse('$_baseUrl/$missionId/reject'),
        headers: _authHeaders(authToken),
        body: json.encode({'reason': reason}),
      );

      _handleResponse(response);
    });
  }

  // Cancel Mission
  Future<void> cancelMission({
    required String missionId,
    required String reason,
    required String authToken,
  }) async {
    return _safeApiCall(() async {
      final response = await _client.post(
        Uri.parse('$_baseUrl/$missionId/cancel'),
        headers: _authHeaders(authToken),
        body: json.encode({'reason': reason}),
      );

      _handleResponse(response);
    });
  }

  // Start Mission
  Future<MissionModel> startMission(String missionId, String authToken) async {
    return _safeApiCall(() async {
      final response = await _client.post(
        Uri.parse('$_baseUrl/$missionId/start'),
        headers: _authHeaders(authToken),
      );

      final data = _handleResponse(response);
      return MissionModel.fromJson(data);
    });
  }

  // Generate OTP
  Future<Map<String, dynamic>> generateOtp(String missionId, String authToken) async {
    return _safeApiCall(() async {
      final response = await _client.post(
        Uri.parse('$_baseUrl/$missionId/generate-otp'),
        headers: _authHeaders(authToken),
      );

      return _handleResponse(response);
    });
  }

  // Validate OTP
  Future<MissionModel> validateOtp({
    required String missionId,
    required String otpCode,
    required String authToken,
  }) async {
    return _safeApiCall(() async {
      final response = await _client.post(
        Uri.parse('$_baseUrl/$missionId/validate-otp'),
        headers: _authHeaders(authToken),
        body: json.encode({'otpCode': otpCode}),
      );

      final data = _handleResponse(response);
      return MissionModel.fromJson(data);
    });
  }

  void dispose() {
    _client.close();
  }
}

class MissionServiceException implements Exception {
  final int statusCode;
  final String message;

  MissionServiceException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'MissionServiceException($statusCode): $message';

  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;
  bool get isNetworkError => statusCode == 0;
}

final missionService = MissionService();
