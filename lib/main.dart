import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'data/repositories/providers.dart';
import 'presentation/screens/main_navigation_screen.dart';
import 'presentation/screens/start_permission_screen.dart';
import 'services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.initialize();
  runApp(const ENewsApp());
}

class ENewsApp extends StatelessWidget {
  const ENewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
      ],
      child: MaterialApp(
        title: 'CHOWK.',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: (() {
          final routes = Map<String, WidgetBuilder>.from(AppRoutes.routes);
          routes.remove(AppRoutes.home);
          return {
            '/': (context) => const StartPermissionScreen(),
            ...routes,
          };
        })(),
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.home) {
            return MaterialPageRoute(
              builder: (_) => const RouteGuard(target: MainNavigationScreen()),
              settings: settings,
            );
          }
          return null;
        },
        onUnknownRoute: (settings) =>
            MaterialPageRoute(builder: (_) => const StartPermissionScreen()),
      ),
    );
  }
}

class RouteGuard extends StatefulWidget {
  const RouteGuard({super.key, required this.target});

  final Widget target;

  @override
  State<RouteGuard> createState() => _RouteGuardState();
}

class _RouteGuardState extends State<RouteGuard> {
  bool? _completed;

  @override
  void initState() {
    super.initState();
    _loadOnboarding();
  }

  Future<void> _loadOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _completed = prefs.getBool('onboarding_complete') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_completed == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_completed!) {
      return const StartPermissionScreen();
    }

    return widget.target;
  }
}
