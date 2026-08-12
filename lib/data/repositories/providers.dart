import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_model.dart';
import 'package:e_news/services/api_service.dart';

class NewsProvider extends ChangeNotifier {
  List<NewsModel> _newsList = [];
  List<NewsModel> _featuredNews = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'सभी';

  List<NewsModel> get newsList => _newsList;
  List<NewsModel> get featuredNews => _featuredNews;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  Future<void> fetchNews({String? category, int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getAllNews(
        category: category,
        page: page,
      );

      final newsData = response['data'] as List<dynamic>? ?? [];

      _newsList = newsData
          .map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
          .toList();

      _selectedCategory = category ?? 'सभी';
      _error = null;
    } catch (e) {
      _error = e.toString();
      _newsList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFeaturedNews() async {
    try {
      final newsData = await ApiService.getFeaturedNews();
      _featuredNews = newsData
          .map((item) => NewsModel.fromJson(item))
          .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _featuredNews = [];
    }
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void reset() {
    _newsList = [];
    _featuredNews = [];
    _isLoading = false;
    _error = null;
    _selectedCategory = 'सभी';
    notifyListeners();
  }
}

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _authToken;
  String? _username;
  String? _email;
  String? _role;
  bool _isLoading = false;
  String? _error;

  static bool isAdminRole(String? role) => role == 'admin' || role == 'super_admin';

  AuthProvider() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        ApiService.setToken(token);
        _authToken = token;
        try {
          final profile = await ApiService.getAuthProfile();
          _username = profile['name'] ?? profile['username'] ?? _username;
          _email = profile['email'] ?? _email;
          _role = profile['role'] ?? _role;
          _isLoggedIn = true;
        } catch (_) {
          _isLoggedIn = false;
        }
        notifyListeners();
      }
    } catch (_) {
      // ignore
    }
  }

  bool get isLoggedIn => _isLoggedIn;
  String? get authToken => _authToken;
  String? get username => _username;
  String? get email => _email;
  String? get role => _role;
  bool get isAdmin => AuthProvider.isAdminRole(_role);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.login(
        email: email,
        password: password,
      );

      final token = response['token'] ?? '';
      _authToken = token;
      ApiService.setToken(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      final profile = await ApiService.getAuthProfile();
      _email = profile['email'] ?? profile['username'];
      _username = profile['name'] ?? profile['username'];
      _role = profile['role'] ?? response['user']?['role'];
      _isLoggedIn = true;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? city,
    String? state,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        city: city,
        state: state,
      );

      final token = response['token'] ?? '';
      _authToken = token;
      ApiService.setToken(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      final profile = await ApiService.getAuthProfile();
      _email = profile['email'] ?? profile['username'];
      _username = profile['name'] ?? profile['username'];
      _role = profile['role'] ?? response['user']?['role'];
      _isLoggedIn = true;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  void logout() {
    _isLoggedIn = false;
    _authToken = null;
    _username = null;
    _email = null;
    _role = null;
    _error = null;
    ApiService.clearToken();
    SharedPreferences.getInstance().then((prefs) => prefs.remove('auth_token'));
    notifyListeners();
  }
}
