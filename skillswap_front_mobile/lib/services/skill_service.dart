import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/skill_model.dart';

/// Skill Service for managing skills
class SkillService {
  static final SkillService _instance = SkillService._internal();
  factory SkillService() => _instance;
  SkillService._internal();

  final http.Client _client = http.Client();
  
  /// Headers for JSON requests
  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Headers with user ID (for authentication)
  Map<String, String> _userHeaders(String userId, {String? authToken}) => {
    ..._jsonHeaders,
    'X-User-Id': userId,
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  /// Base URL for the Skill API
  String get _baseUrl => ApiConfig.skillServiceUrl;

  /// Handle API response and throw exception if needed
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
      
      throw SkillServiceException(
        statusCode: response.statusCode,
        message: message,
      );
    }
  }

  /// Wrap API calls with error handling
  Future<T> _safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on SocketException {
      throw SkillServiceException(
        statusCode: 0,
        message: 'No internet connection. Please check your network.',
      );
    } on HttpException catch (e) {
      throw SkillServiceException(
        statusCode: 0,
        message: 'HTTP Error: ${e.message}',
      );
    } on FormatException {
      throw SkillServiceException(
        statusCode: 0,
        message: 'Invalid response format from server.',
      );
    }
  }

  // ==================== Skill APIs ====================

  /// Create a new skill
  Future<SkillModel> createSkill({
    required String userId,
    required String title,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    String? authToken,
  }) async {
    return _safeApiCall(() async {
      final request = CreateSkillRequest(
        title: title,
        description: description,
        category: category,
        latitude: latitude,
        longitude: longitude,
      );

      final response = await _client.post(
        Uri.parse('$_baseUrl${SkillEndpoints.all}'),
        headers: _userHeaders(userId, authToken: authToken),
        body: json.encode(request.toJson()),
      );

      final data = _handleResponse(response);
      return SkillModel.fromJson(data);
    });
  }

  /// Get skills near a location
  Future<List<SkillModel>> getSkillsNear({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? category,
  }) async {
    return _safeApiCall(() async {
      final queryParams = {
        'lat': latitude.toString(),
        'lng': longitude.toString(),
        'radius': radiusKm.toString(),
        if (category != null && category.isNotEmpty) 'category': category,
      };

      final uri = Uri.parse('$_baseUrl${SkillEndpoints.near}')
          .replace(queryParameters: queryParams);

      final response = await _client.get(uri, headers: _jsonHeaders);

      final data = _handleResponse(response) as List;
      return data.map((e) => SkillModel.fromJson(e)).toList();
    });
  }

  /// Get skills by user ID
  Future<List<SkillModel>> getSkillsByUser(String userId) async {
    return _safeApiCall(() async {
      final response = await _client.get(
        Uri.parse('$_baseUrl${SkillEndpoints.byUser(userId)}'),
        headers: _jsonHeaders,
      );

      final data = _handleResponse(response) as List;
      return data.map((e) => SkillModel.fromJson(e)).toList();
    });
  }

  /// Get a skill by ID
  Future<SkillModel> getSkillById(String skillId) async {
    return _safeApiCall(() async {
      final response = await _client.get(
        Uri.parse('$_baseUrl${SkillEndpoints.byId(skillId)}'),
        headers: _jsonHeaders,
      );

      final data = _handleResponse(response);
      return SkillModel.fromJson(data);
    });
  }

  /// Update a skill
  Future<SkillModel> updateSkill({
    required String skillId,
    required String userId,
    String? title,
    String? description,
    String? category,
    double? latitude,
    double? longitude,
    bool? active,
    String? authToken,
  }) async {
    return _safeApiCall(() async {
      final request = UpdateSkillRequest(
        title: title,
        description: description,
        category: category,
        latitude: latitude,
        longitude: longitude,
        active: active,
      );

      final response = await _client.put(
        Uri.parse('$_baseUrl${SkillEndpoints.byId(skillId)}'),
        headers: _userHeaders(userId, authToken: authToken),
        body: json.encode(request.toJson()),
      );

      final data = _handleResponse(response);
      return SkillModel.fromJson(data);
    });
  }

  /// Delete a skill
  Future<void> deleteSkill({
    required String skillId,
    required String userId,
    String? authToken,
  }) async {
    return _safeApiCall(() async {
      final response = await _client.delete(
        Uri.parse('$_baseUrl${SkillEndpoints.byId(skillId)}'),
        headers: _userHeaders(userId, authToken: authToken),
      );

      _handleResponse(response);
    });
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}

/// Exception for Skill Service errors
class SkillServiceException implements Exception {
  final int statusCode;
  final String message;

  SkillServiceException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'SkillServiceException($statusCode): $message';

  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;
  bool get isNetworkError => statusCode == 0;
}

/// Global skill service instance
final skillService = SkillService();
