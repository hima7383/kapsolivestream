// api_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiRepository {
  static const String baseUrl = 'http://31.97.185.64:3000/';
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Helper method for GET requests
  Future<dynamic> _get(String endpoint, {Map<String, String>? queryParams}) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API request failed: ${response.statusCode}');
    }
  }

  // Get default user profile data
  Future<Map<String, dynamic>> getProfile() async {
    return await _get('profile');
  }

  // Get user media (posts or reels) - now using GET with query parameter
  Future<List<dynamic>> getProfileMedia(String flag) async {
    final response = await _get(
      'profile/media',
      queryParams: {'flag': flag},
    );
    return List.from(response);
  }

  // Get user posts
  Future<List<dynamic>> getPosts() => getProfileMedia('posts');

  // Get user reels
  Future<List<dynamic>> getReels() => getProfileMedia('reels');
}

// Example usage:
/*
void main() async {
  final api = ApiRepository();
  
  try {
    // Get user profile
    final profile = await api.getProfile();
    print('User Profile: $profile');
    
    // Get posts using GET request
    final posts = await api.getPosts();
    print('Posts: ${posts.length}');
    
    // Get reels using GET request
    final reels = await api.getReels();
    print('Reels: ${reels.length}');
  } catch (e) {
    print('Error: $e');
  }
}
*/