import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ==================== MODELS ====================
class Post {
  final String id;
  final String userId;
  final String content;
  final List<String> media;
  final String privacy;
  final List<String> tags;
  final List<String> likes;
  final int commentsCount;
  final int shares;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.media,
    required this.privacy,
    required this.tags,
    required this.likes,
    required this.commentsCount,
    required this.shares,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
 String toString() {
    return 'Post{id: $id, userId: $userId, content: $content, media: $media, privacy: $privacy, tags: $tags, likes: $likes, commentsCount: $commentsCount, shares: $shares, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      content: json['content'] ?? '',
      media: List<String>.from(json['media'] ?? []),
      privacy: json['privacy'] ?? 'public',
      tags: List<String>.from(json['tags'] ?? []),
      likes: List<String>.from(json['likes'] ?? []),
      commentsCount: json['commentsCount'] ?? 0,
      shares: json['shares'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class UserProfile {
  final String id;
  final String username;
  final String phoneNumber;
  final String role;
  final String profileImage;
  final bool blocked;
  final String country;
  final List<dynamic> fcmTokens;

  UserProfile({
    required this.id,
    required this.username,
    required this.phoneNumber,
    required this.role,
    required this.profileImage,
    required this.blocked,
    required this.country,
    required this.fcmTokens,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? 'user',
      profileImage: json['profileImage'] ?? '',
      blocked: json['blocked'] ?? false,
      country: json['country'] ?? '',
      fcmTokens: List<dynamic>.from(json['fcmTokens'] ?? []),
    );
  }
}

class ProfileResponse {
  final UserProfile userData;
  final List<dynamic> userReels;

  ProfileResponse({
    required this.userData,
    required this.userReels,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      userData: UserProfile.fromJson(json['userData'] ?? {}),
      userReels: List<dynamic>.from(json['userReels'] ?? []),
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final dynamic message; // Can be String or Map
  final T data;

  ApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: fromJsonT(json['data']),
    );
  }
}

// ==================== REPOSITORY ====================
class ApiRepository {
  static const String baseUrl = 'http://31.97.185.64:3000/';
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<dynamic> _get(String endpoint, {Map<String, dynamic>? body}) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final uri = Uri.parse('$baseUrl$endpoint');
    
    final request = http.Request('GET', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
    
    if (body != null) {
      request.body = jsonEncode(body);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final responseBody = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      final errorMessage = responseBody['message'] ?? 'API request failed';
      throw ApiException(
        statusCode: response.statusCode,
        message: errorMessage.toString(),
        response: responseBody,
      );
    }
  }

  // Profile Methods
 Future<ApiResponse<ProfileResponse>> getProfile() async {
  final response = await _get('profile');
  return ApiResponse.fromJson(
    response,
    (_) => ProfileResponse.fromJson(response['message']), // Handle Map message
  );
}

  // Post Methods
  Future<ApiResponse<List<Post>>> getPosts() async {
  final response = await _get(
    'profile/media',
    body: {'flag': 'posts'},
  );
  
  return ApiResponse.fromJson(
    response,
    (data) => (data['posts'] as List).map((post) => Post.fromJson(post)).toList(),
  );
}

  Future<ApiResponse<List<Post>>> getReels() async {
    final response = await _get(
      'profile/media',
      body: {'flag': 'reels'},
    );
    
    final reelsData = response['data']['posts'] as List;
    return ApiResponse.fromJson(
      response,
      (_) => reelsData.map((reel) => Post.fromJson(reel)).toList(),
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic response;

  ApiException({
    required this.statusCode,
    required this.message,
    this.response,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status $statusCode)';
  }
}