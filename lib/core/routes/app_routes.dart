import 'package:flutter/material.dart';
import '../../presentation/screens/main_navigation_screen.dart';
import '../../presentation/screens/start_permission_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/news/news_detail_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/admin/admin_upload_screen.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/admin_live_screen.dart';
import '../../presentation/screens/media/chowk_patrika_screen.dart';
import '../../presentation/screens/media/chowk_charcha_screen.dart';
import '../../presentation/screens/media/podcast_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String newsDetail = '/news-detail';
  static const String profile = '/profile';
  static const String chowkPatrika = '/chowk-patrika';
  static const String chowkCharcha = '/chowk-charcha';
  static const String podcasts = '/podcasts';
  static const String adminUpload = '/admin/upload';
  static const String adminLive = '/admin/live';
  static const String adminDashboard = '/admin/dashboard';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const MainNavigationScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    profile: (context) => const ProfileScreen(),
    chowkPatrika: (context) => const ChowkPatrikaScreen(),
    chowkCharcha: (context) => const ChowkCharchaScreen(),
    podcasts: (context) => const PodcastScreen(),
    adminUpload: (context) => const AdminUploadScreen(),
    adminLive: (context) => const AdminLiveScreen(),
    adminDashboard: (context) => const AdminDashboardScreen(),
  };
}
