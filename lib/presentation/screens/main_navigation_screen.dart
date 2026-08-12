import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../data/repositories/providers.dart';
import '../widgets/auth_modal.dart';
import 'home_screen.dart';
import 'profile/profile_screen.dart';
import 'start_permission_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _permissionChecked = false;

  late final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const BookmarksScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_complete') ?? false;
    if (!completed) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const StartPermissionScreen()),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _permissionChecked = true);
  }

  void _openMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'एक्सप्लोर करें',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.chowkBlack,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close, color: AppTheme.chowkBlack),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                sheetContext,
                Icons.article_outlined,
                'चौक पत्रिका',
                AppRoutes.chowkPatrika,
              ),
              _buildMenuTile(
                sheetContext,
                Icons.chat_bubble_outline,
                'चौक चर्चा',
                AppRoutes.chowkCharcha,
              ),
              _buildMenuTile(
                sheetContext,
                Icons.podcasts,
                'पॉडकास्ट',
                AppRoutes.podcasts,
              ),
              _buildMenuTile(
                sheetContext,
                Icons.person_outline,
                'प्रोफाइल',
                AppRoutes.profile,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    IconData icon,
    String title,
    String routeName,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.chowkOrange),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppTheme.chowkBlack,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.mutedText,
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(routeName);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;

    if (!isLoggedIn && _currentIndex == 3) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: _permissionChecked
          ? (_currentIndex == 3 && !isLoggedIn ? _screens[0] : _screens[_currentIndex])
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openMenu(context),
        icon: const Icon(Icons.menu),
        label: const Text('मेनू'),
        backgroundColor: AppTheme.chowkOrange,
        foregroundColor: AppTheme.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavBar(isLoggedIn),
    );
  }

  Widget _buildBottomNavBar(bool isLoggedIn) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: AppShadows.largeList,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildNavItem(icon: Icons.home_rounded, label: 'होम', index: 0, isLoggedIn: isLoggedIn),
              ),
              Expanded(
                child: _buildNavItem(icon: Icons.search_rounded, label: 'खोज', index: 1, isLoggedIn: isLoggedIn),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.bookmark_rounded,
                  label: 'बुकमार्क',
                  index: 2,
                  isLoggedIn: isLoggedIn,
                ),
              ),
              if (isLoggedIn) ...[
                Expanded(
                  child: _buildNavItem(
                    icon: Icons.person_rounded,
                    label: 'प्रोफ़ाइल',
                    index: 3,
                    isLoggedIn: isLoggedIn,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isLoggedIn,
  }) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 3 && !isLoggedIn) {
          showAuthModal(context);
          return;
        }
        setState(() => _currentIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80,
        height: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.primaryRed : AppTheme.mutedText,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  List<String> _recentSearches = ['राजनीति', 'खेल', 'बिजनेस'];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String value) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: const TextStyle(
            color: AppTheme.chowkBlack,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: 'समाचार खोजें...',
            hintStyle: TextStyle(
              color: AppTheme.chowkBlack.withOpacity(0.72),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppTheme.lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.secondaryBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.chowkOrange,
                width: 1.5,
              ),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppTheme.chowkBlack.withOpacity(0.7),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      _handleSearchChanged('');
                    },
                  )
                : null,
          ),
          onChanged: _handleSearchChanged,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('हाल की खोजें', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches
                  .map(
                    (search) => GestureDetector(
                      onTap: () {
                        _searchController.text = search;
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          border: Border.all(color: AppTheme.mediumGray),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history,
                              size: 16,
                              color: AppTheme.mutedText,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              search,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(title: const Text('सहेजे गए समाचार'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.lightRed,
                ),
                child: const Icon(
                  Icons.bookmark,
                  size: 50,
                  color: AppTheme.primaryRed,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'कोई सहेजे गए समाचार नहीं',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'जब आप कोई समाचार सहेजते हैं तो वह यहां दिखाई देगा',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
