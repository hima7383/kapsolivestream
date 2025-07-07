import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Common Models
class User {
  final String id;
  final String? username;

  User({
    required this.id,
    this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      username: json['username'],
    );
  }
}

class Media {
  final String type;
  final String url;
  final String id;

  Media({
    required this.type,
    required this.url,
    required this.id,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      type: json['type'] ?? 'image',
      url: json['url'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}

class Like {
  final String userId;
  final DateTime createdAt;

  Like({
    required this.userId,
    required this.createdAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int limit;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalPosts'] ?? json['totalReels'] ?? 0,
      limit: json['limit'] ?? 20,
    );
  }
}

// Post Models
class Post {
  final String id;
  final User user;
  final String content;
  final List<Media> media;
  final String privacy;
  final List<String> tags;
  final List<Like> likes;
  final int commentsCount;
  final int shares;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.user,
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

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] ?? '',
      user: User.fromJson(json['userId'] ?? {}),
      content: json['content'] ?? '',
      media: (json['media'] as List<dynamic>?)
              ?.map((x) => Media.fromJson(x ?? {}))
              .toList() ??
          [],
      privacy: json['privacy'] ?? 'public',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      likes: (json['likes'] as List<dynamic>?)
              ?.map((x) => Like.fromJson(x ?? {}))
              .toList() ??
          [],
      commentsCount: json['commentsCount'] ?? 0,
      shares: json['shares'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
    );
  }
}

class PostsResponse {
  final List<Post> posts;
  final Pagination pagination;

  PostsResponse({
    required this.posts,
    required this.pagination,
  });

  factory PostsResponse.fromJson(Map<String, dynamic> json) {
    return PostsResponse(
      posts: (json['posts'] as List<dynamic>?)
              ?.map((x) => Post.fromJson(x ?? {}))
              .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

// Reel Models
class Reel {
  final String id;
  final String caption;
  final String userId;
  final List<String> url;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Like> likes;
  final int commentsCount;
  final int shares;

  Reel({
    required this.id,
    required this.caption,
    required this.userId,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
    this.likes = const [],
    this.commentsCount = 0,
    this.shares = 0,
  });

  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      id: json['_id'] ?? '',
      caption: json['caption'] ?? '',
      userId: json['users'] ?? '',
      url: (json['url'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
      likes: (json['likes'] as List<dynamic>?)
              ?.map((x) => Like.fromJson(x ?? {}))
              .toList() ??
          [],
      commentsCount: json['commentsCount'] ?? 0,
      shares: json['shares'] ?? 0,
    );
  }
}

class ReelsResponse {
  final List<Reel> reels;
  final Pagination pagination;

  ReelsResponse({
    required this.reels,
    required this.pagination,
  });

  factory ReelsResponse.fromJson(Map<String, dynamic> json) {
    return ReelsResponse(
      reels: (json['reels'] as List<dynamic>?)
              ?.map((x) => Reel.fromJson(x ?? {}))
              .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

// Repository
class PostRepository {
  static const String _baseUrl = 'http://31.97.185.64:3000';
  final http.Client client;

  PostRepository({http.Client? client}) : client = client ?? http.Client();

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('authToken');
    } catch (e) {
      return null;
    }
  }

  Future<PostsResponse> getPosts({int page = 1}) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/post?page=$page'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return PostsResponse.fromJson(jsonResponse['data'] ?? {});
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to load posts');
        }
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  Future<ReelsResponse> getReels({int page = 1}) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/reels/getAllReels?page=$page'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          // Transform the response to match our expected structure
          final data = jsonResponse['data'] ?? {};
          return ReelsResponse(
            reels: (data['reels'] as List<dynamic>?)
                    ?.map((x) => Reel.fromJson(x ?? {}))
                    .toList() ??
                [],
            pagination: Pagination(
              currentPage: page,
              totalPages: 1, // Adjust based on your API response
              totalItems: data['reels']?.length ?? 0,
              limit: 20,
            ),
          );
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to load reels');
        }
      } else {
        throw Exception('Failed to load reels: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch reels: $e');
    }
  }

  void dispose() {
    client.close();
  }
}