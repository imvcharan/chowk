import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../data/mock/mock_data.dart';

class ApiService {
  // The NestJS API is the only supported backend.
  static String? _customBaseUrl;

  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    if (kIsWeb) {
      return 'http://localhost:3001/api/v1';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3001/api/v1';
    }
    return 'http://127.0.0.1:3001/api/v1';
  }

  static const Duration timeout = Duration(seconds: 30);
  static String? _token;

  // Set auth token (call this after login)
  static void setToken(String token) {
    _token = token;
  }

  // Clear auth token (call this on logout)
  static void clearToken() {
    _token = null;
  }

  static Future<void> initialize() async {
    try {
      final raw = await rootBundle.loadString('assets/config.json');
      final data = jsonDecode(raw);
      if (data is Map && data['apiBaseUrl'] != null) {
        final apiBaseUrl = data['apiBaseUrl'].toString().trim();
        if (apiBaseUrl.isNotEmpty) {
          _customBaseUrl = apiBaseUrl;
        }
      }
    } catch (_) {
      // ignore config load errors and fall back to built-in defaults
    }
  }

  static String normalizeMediaUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return value;
    final apiUri = Uri.parse(baseUrl);
    if (uri.host != 'localhost' && uri.host != '127.0.0.1') return value;
    return uri.replace(host: apiUri.host, port: uri.hasPort ? uri.port : null).toString();
  }

  // Get authorization headers
  static Map<String, String> _getHeaders({bool withAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // ==================== AUTH ENDPOINTS ====================

  /// Register new user
  /// Returns: {success: bool, token: String, user: {id, name, email, role}}
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? city,
    String? state,
  }) async {
    try {
      final requestBody = {
        'action': 'register',
        'username': name,
        'email': email,
        'password': password,
        if (city != null && city.isNotEmpty) 'city': city,
        if (state != null && state.isNotEmpty) 'state': state,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if ((response.statusCode == 201 || response.statusCode == 200) && data['success']) {
        setToken(data['token']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'रजिस्ट्रेशन विफल');
      }
    } catch (e) {
      throw Exception('रजिस्ट्रेशन त्रुटि: $e');
    }
  }

  /// Login user
  /// Returns: {success: bool, token: String, user: {id, name, email, role}}
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'action': 'login',
          'email': email,
          'password': password,
        }),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        setToken(data['token']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'लॉगिन विफल');
      }
    } catch (e) {
      throw Exception('लॉगिन त्रुटि: $e');
    }
  }

  /// Get current user profile
  static Future<Map<String, dynamic>> getAuthProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: _getHeaders(withAuth: true),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data['data'];
      } else {
        throw Exception('प्रोफाइल लोड विफल');
      }
    } catch (e) {
      throw Exception('प्रोफाइल लोड त्रुटि: $e');
    }
  }

  // ==================== NEWS ENDPOINTS ====================

  /// Get all news with pagination and filters
  /// Parameters: page, limit, category (slug), search, featured
  static Future<Map<String, dynamic>> getAllNews({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    bool? featured,
  }) async {
    try {
      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (category != null) 'category': category,
        if (search != null) 'search': search,
        if (featured != null) 'featured': featured.toString(),
      };

      final uri = Uri.parse('$baseUrl/news').replace(queryParameters: params);
      final response = await http.get(
        uri,
        headers: _getHeaders(),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        final d = data['data'];
        if (d == null || (d is List && d.isEmpty) || (d is Map && d.isEmpty)) {
          return MockData.allNews(page: page, limit: limit);
        }
        return data;
      } else {
        throw Exception(data['message'] ?? 'समाचार लोड विफल');
      }
    } catch (e) {
      // Fallback to mock data when backend unreachable
      try {
        return MockData.allNews(page: page, limit: limit);
      } catch (_) {
        throw Exception('समाचार लोड त्रुटि: $e');
      }
    }
  }

  /// Get featured news
  static Future<List<dynamic>> getFeaturedNews({int limit = 5}) async {
    try {
      final response = await getAllNews(featured: true, limit: limit);
      final data = response['data'] ?? [];
      if (data.isEmpty) return MockData.featuredNews();
      return data;
    } catch (e) {
      // Return mock featured
      return MockData.featuredNews();
    }
  }

  /// Get news detail by ID
  static Future<Map<String, dynamic>> getNewsDetail(int newsId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/news/$newsId'),
        headers: _getHeaders(),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'समाचार नहीं मिला');
      }
    } catch (e) {
      throw Exception('समाचार विवरण त्रुटि: $e');
    }
  }

  /// Create new news (admin/editor only)
  static Future<Map<String, dynamic>> createNews({
    required String title,
    required String description,
    required String content,
    required int categoryId,
    int? authorId,
    String? imageUrl,
    bool featured = false,
    bool isPublished = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/news'),
        headers: _getHeaders(withAuth: true),
        body: jsonEncode({
          'title': title,
          'description': description,
          'content': content,
          'category_id': categoryId,
          if (authorId != null) 'author_id': authorId,
          'image_url': imageUrl,
          'featured': featured,
          'is_published': isPublished,
        }),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'समाचार बनाना विफल');
      }
    } catch (e) {
      throw Exception('समाचार बनाने त्रुटि: $e');
    }
  }

  /// Create live update for real-time reporting
  static Future<Map<String, dynamic>> createLiveUpdate({
    required String title,
    required String body,
    String? imageUrl,
    String? videoUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/live'),
        headers: _getHeaders(withAuth: true),
        body: jsonEncode({
          'title': title,
          'body': body,
          if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
          if (videoUrl != null && videoUrl.isNotEmpty) 'video_url': videoUrl,
        }),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if ((response.statusCode == 201 || response.statusCode == 200) && data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'लाइव अपडेट भेजना विफल');
      }
    } catch (e) {
      throw Exception('लाइव अपडेट त्रुटि: $e');
    }
  }

  /// Update a live report
  static Future<Map<String, dynamic>> updateLiveUpdate({
    required int id,
    required String title,
    required String body,
    String? imageUrl,
    String? videoUrl,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/live').replace(queryParameters: {
        'id': id.toString(),
      });

      final response = await http.put(
        uri,
        headers: _getHeaders(withAuth: true),
        body: jsonEncode({
          'title': title,
          'body': body,
          if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
          if (videoUrl != null && videoUrl.isNotEmpty) 'video_url': videoUrl,
        }),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'लाइव अपडेट अपडेट करना विफल');
      }
    } catch (e) {
      throw Exception('लाइव अपडेट अपडेट त्रुटि: $e');
    }
  }

  /// Upload media (image/video) - multipart/form-data
  /// Returns: {success: bool, url: String}
  static Future<Map<String, dynamic>> uploadMedia({
    required String filePath,
    String field = 'file',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/media');
      final request = http.MultipartRequest('POST', uri);

      // Attach headers (authorization)
      final headers = _getHeaders(withAuth: true);
      request.headers.addAll(headers);

      final file = File(filePath);
      if (!file.existsSync()) throw Exception('File not found: $filePath');

      final multipartFile = await http.MultipartFile.fromPath(field, file.path);
      request.files.add(multipartFile);

      final streamed = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body);

      if ((response.statusCode == 201 || response.statusCode == 200) && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Upload failed');
      }
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  /// Submit a report for a news item
  static Future<Map<String, dynamic>> reportNews({
    required int newsId,
    required String reason,
    String? details,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reports'),
        headers: _getHeaders(withAuth: true),
        body: jsonEncode({
          'news_id': newsId,
          'reason': reason,
          'details': details,
        }),
      ).timeout(timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success']) {
        return data;
      } else if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Report failed');
      }
    } catch (e) {
      throw Exception('Report error: $e');
    }
  }

  /// Update news (admin/editor only)
  static Future<Map<String, dynamic>> updateNews(
    int newsId, {
    String? title,
    String? description,
    String? content,
    int? categoryId,
    String? imageUrl,
    bool? featured,
    bool? isPublished,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (content != null) body['content'] = content;
      if (categoryId != null) body['category_id'] = categoryId;
      if (imageUrl != null) body['image_url'] = imageUrl;
      if (featured != null) body['featured'] = featured;
      if (isPublished != null) body['is_published'] = isPublished;

      final response = await http.put(
        Uri.parse('$baseUrl/news/$newsId'),
        headers: _getHeaders(withAuth: true),
        body: jsonEncode(body),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'समाचार अपडेट विफल');
      }
    } catch (e) {
      throw Exception('समाचार अपडेट त्रुटि: $e');
    }
  }

  /// Delete news (admin only)
  static Future<bool> deleteNews(int newsId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/news/$newsId'),
        headers: _getHeaders(withAuth: true),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'समाचार हटाना विफल');
      }
    } catch (e) {
      throw Exception('समाचार हटाने त्रुटि: $e');
    }
  }

  // ==================== CATEGORY ENDPOINTS ====================

  /// Get all categories
  static Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: _getHeaders(),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data['data'] ?? [];
      } else {
        throw Exception('श्रेणियां लोड विफल');
      }
    } catch (e) {
      throw Exception('श्रेणियां लोड त्रुटि: $e');
    }
  }

  /// Get all admin users
  static Future<List<dynamic>> getAdminUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: _getHeaders(withAuth: true),
      ).timeout(timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        return data['data'] ?? [];
      } else {
        throw Exception(data['message'] ?? 'Users load failed');
      }
    } catch (e) {
      throw Exception('Users load error: $e');
    }
  }

  /// Update user role (admin only)
  static Future<bool> updateUserRole(int userId, String role) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/users/$userId/role'),
        headers: _getHeaders(withAuth: true),
        body: jsonEncode({'role': role}),
      ).timeout(timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'Role update failed');
      }
    } catch (e) {
      throw Exception('Role update error: $e');
    }
  }

  /// Create user (admin only)
  static Future<Map<String, dynamic>> createAdminUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? city,
    String? state,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/users'),
        headers: _getHeaders(withAuth: true),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          if (city != null && city.isNotEmpty) 'city': city,
          if (state != null && state.isNotEmpty) 'state': state,
        }),
      ).timeout(timeout);

      final data = jsonDecode(response.body);
      if ((response.statusCode == 201 || response.statusCode == 200) && data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Create user failed');
      }
    } catch (e) {
      throw Exception('Create user error: $e');
    }
  }

  /// Delete user (admin only)
  static Future<bool> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: _getHeaders(withAuth: true),
      ).timeout(timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'Delete user failed');
      }
    } catch (e) {
      throw Exception('Delete user error: $e');
    }
  }

  /// Create category (admin only)
  static Future<Map<String, dynamic>> createCategory({
    required String name,
    String? description,
    String? color,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: _getHeaders(withAuth: true),
        body: jsonEncode({
          'name': name,
          'description': description,
          'color': color,
        }),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'श्रेणी बनाना विफल');
      }
    } catch (e) {
      throw Exception('श्रेणी बनाने त्रुटि: $e');
    }
  }

  /// Update category (admin only)
  static Future<Map<String, dynamic>> updateCategory({
    required int categoryId,
    required String name,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/categories/$categoryId'),
        headers: _getHeaders(withAuth: true),
        body: jsonEncode({
          'name': name,
          'slug': name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), ''),
        }),
      ).timeout(timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'श्रेणी अपडेट विफल');
      }
    } catch (e) {
      throw Exception('श्रेणी अपडेट त्रुटि: $e');
    }
  }

  /// Delete category (admin only)
  static Future<bool> deleteCategory(int categoryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/categories/$categoryId'),
        headers: _getHeaders(withAuth: true),
      ).timeout(timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'श्रेणी हटाना विफल');
      }
    } catch (e) {
      throw Exception('श्रेणी हटाने त्रुटि: $e');
    }
  }

  // ==================== BOOKMARK ENDPOINTS ====================

  /// Get user bookmarks
  static Future<List<dynamic>> getBookmarks({int page = 1, int limit = 20}) async {
    try {
      final uri = Uri.parse('$baseUrl/bookmarks').replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });

      final response = await http.get(
        uri,
        headers: _getHeaders(withAuth: true),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data['data'] ?? [];
      } else {
        throw Exception('बुकमार्क लोड विफल');
      }
    } catch (e) {
      throw Exception('बुकमार्क लोड त्रुटि: $e');
    }
  }

  /// Add bookmark
  static Future<bool> addBookmark(int newsId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookmarks'),
        headers: _getHeaders(withAuth: true),
        body: jsonEncode({'news_id': newsId}),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success']) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'बुकमार्क जोड़ना विफल');
      }
    } catch (e) {
      throw Exception('बुकमार्क जोड़ने त्रुटि: $e');
    }
  }

  /// Remove bookmark
  static Future<bool> removeBookmark(int newsId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/bookmarks/$newsId'),
        headers: _getHeaders(withAuth: true),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'बुकमार्क हटाना विफल');
      }
    } catch (e) {
      throw Exception('बुकमार्क हटाने त्रुटि: $e');
    }
  }

  // ==================== COMMENT ENDPOINTS ====================

  /// Get comments for news
  static Future<List<dynamic>> getComments(int newsId,
      {int page = 1, int limit = 10}) async {
    try {
      final uri = Uri.parse('$baseUrl/comments/$newsId').replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });

      final response = await http.get(
        uri,
        headers: _getHeaders(),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data['data'] ?? [];
      } else {
        throw Exception('टिप्पणियां लोड विफल');
      }
    } catch (e) {
      throw Exception('टिप्पणियां लोड त्रुटि: $e');
    }
  }

  /// Add comment
  static Future<Map<String, dynamic>> addComment(
    int newsId,
    String content,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/comments/$newsId'),
        headers: _getHeaders(withAuth: true),
        body: jsonEncode({'content': content}),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'टिप्पणी जोड़ना विफल');
      }
    } catch (e) {
      throw Exception('टिप्पणी जोड़ने त्रुटि: $e');
    }
  }

  /// Delete comment
  static Future<bool> deleteComment(int commentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/comments/$commentId'),
        headers: _getHeaders(withAuth: true),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'टिप्पणी हटाना विफल');
      }
    } catch (e) {
      throw Exception('टिप्पणी हटाने त्रुटि: $e');
    }
  }

  // ==================== LIKE ENDPOINTS ====================

  /// Get like info
  static Future<Map<String, dynamic>> getLikeInfo(int newsId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/likes/$newsId'),
        headers: _getHeaders(withAuth: true),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data['data'];
      } else {
        throw Exception('लाइक जानकारी लोड विफल');
      }
    } catch (e) {
      throw Exception('लाइक जानकारी त्रुटि: $e');
    }
  }

  /// Like news
  static Future<bool> likeNews(int newsId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/likes/$newsId'),
        headers: _getHeaders(withAuth: true),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success']) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'पसंद करना विफल');
      }
    } catch (e) {
      throw Exception('पसंद करने त्रुटि: $e');
    }
  }

  /// Unlike news
  static Future<bool> unlikeNews(int newsId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/likes/$newsId'),
        headers: _getHeaders(withAuth: true),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'पसंद हटाना विफल');
      }
    } catch (e) {
      throw Exception('पसंद हटाने त्रुटि: $e');
    }
  }

  // ==================== USER PROFILE ENDPOINTS ====================

  /// Get user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: _getHeaders(withAuth: true),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data['data'];
      } else {
        throw Exception('प्रोफाइल लोड विफल');
      }
    } catch (e) {
      throw Exception('प्रोफाइल लोड त्रुटि: $e');
    }
  }

  /// Update user profile
  static Future<bool> updateProfile({
    String? name,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (bio != null) body['bio'] = bio;
      if (avatarUrl != null) body['avatar_url'] = avatarUrl;

      final response = await http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: _getHeaders(withAuth: true),
        body: jsonEncode(body),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'प्रोफाइल अपडेट विफल');
      }
    } catch (e) {
      throw Exception('प्रोफाइल अपडेट त्रुटि: $e');
    }
  }

  /// Change password
  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/profile?action=change-password'),
        headers: _getHeaders(withAuth: true),
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'पासवर्ड बदलना विफल');
      }
    } catch (e) {
      throw Exception('पासवर्ड बदलने त्रुटि: $e');
    }
  }

  // ==================== TRENDING ENDPOINTS ====================

  /// Get trending news
  static Future<List<dynamic>> getTrendingNews({int limit = 10}) async {
    try {
      final uri = Uri.parse('$baseUrl/trending').replace(queryParameters: {
        'limit': limit.toString(),
      });

      final response = await http.get(
        uri,
        headers: _getHeaders(),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        final d = data['data'] ?? [];
        if (d is List && d.isNotEmpty) return d;
        return MockData.trendingNews();
      } else {
        throw Exception('ट्रेंडिंग लोड विफल');
      }
    } catch (e) {
        return MockData.trendingNews();
    }
  }

  /// Get live updates (short headlines for live reporting)
  static Future<List<dynamic>> getLiveUpdates({int limit = 20}) async {
    try {
      final uri = Uri.parse('$baseUrl/live').replace(queryParameters: {
        'limit': limit.toString(),
      });

      final response = await http.get(
        uri,
        headers: _getHeaders(),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        final d = data['data'] ?? [];
        if (d is List && d.isNotEmpty) return d;
        return MockData.liveUpdates();
      } else {
        throw Exception('लाइव अपडेट लोड विफल');
      }
    } catch (e) {
        return MockData.liveUpdates();
    }
  }

  /// Delete a live report by ID
  static Future<void> deleteLiveUpdate(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/live').replace(queryParameters: {
        'id': id.toString(),
      });

      final response = await http.delete(
        uri,
        headers: _getHeaders(withAuth: true),
      ).timeout(timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to delete live update');
      }
    } catch (e) {
      throw Exception('लाइव अपडेट हटाने में त्रुटि: $e');
    }
  }

  /// List streams that are currently marked LIVE by a publisher.
  static Future<List<Map<String, dynamic>>> getLiveStreams() async {
    final response = await http.get(
      Uri.parse('$baseUrl/streams'),
      headers: _getHeaders(),
    ).timeout(timeout);
    final data = jsonDecode(response.body);
    if (response.statusCode != 200 || data is! List) {
      throw Exception('लाइव स्ट्रीम लोड करना विफल');
    }
    return data.map<Map<String, dynamic>>((item) {
      final stream = Map<String, dynamic>.from(item as Map);
      if (stream['playbackUrl'] != null) {
        stream['playbackUrl'] = normalizeMediaUrl(stream['playbackUrl'].toString());
      }
      return stream;
    }).toList();
  }

  /// Create a stream session and return the RTMP ingest credentials.
  static Future<Map<String, dynamic>> createLiveStream({
    required String title,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/streams'),
      headers: _getHeaders(withAuth: true),
      body: jsonEncode({
        'title': title,
        if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
      }),
    ).timeout(timeout);
    final data = jsonDecode(response.body);
    if (response.statusCode != 201 || data is! Map<String, dynamic>) {
      throw Exception(data is Map ? data['message'] ?? 'लाइव स्ट्रीम बनाना विफल' : 'लाइव स्ट्रीम बनाना विफल');
    }
    final stream = Map<String, dynamic>.from(data);
    for (final key in ['playbackUrl', 'ingestUrl', 'whipUrl']) {
      final value = stream[key];
      if (value is String && value.isNotEmpty) {
        stream[key] = normalizeMediaUrl(value);
      }
    }
    return stream;
  }

  /// Mark a stream LIVE after the broadcaster has connected, or ENDED when done.
  static Future<Map<String, dynamic>> updateLiveStream({
    required String id,
    required String status,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/streams/$id'),
      headers: _getHeaders(withAuth: true),
      body: jsonEncode({'status': status}),
    ).timeout(timeout);
    final data = jsonDecode(response.body);
    if (response.statusCode != 200 || data is! Map<String, dynamic>) {
      throw Exception(data is Map ? data['message'] ?? 'लाइव स्ट्रीम अपडेट करना विफल' : 'लाइव स्ट्रीम अपडेट करना विफल');
    }
    return Map<String, dynamic>.from(data);
  }

  // ==================== SEARCH ENDPOINTS ====================

  /// Search news
  static Future<List<dynamic>> searchNews(String query) async {
    try {
      final uri = Uri.parse('$baseUrl/search').replace(queryParameters: {
        'q': query,
      });

      final response = await http.get(
        uri,
        headers: _getHeaders(),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data['data'] ?? [];
      } else {
        throw Exception('खोज विफल');
      }
    } catch (e) {
      throw Exception('खोज त्रुटि: $e');
    }
  }
}
