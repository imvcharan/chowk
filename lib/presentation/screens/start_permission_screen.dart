import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../presentation/widgets/chowk_logo.dart';
import '../../services/notification_service.dart';
import '../../services/permission_service.dart';

class StartPermissionScreen extends StatefulWidget {
  const StartPermissionScreen({super.key});

  @override
  State<StartPermissionScreen> createState() => _StartPermissionScreenState();
}

class _StartPermissionScreenState extends State<StartPermissionScreen> {
  bool _allowNotifications = true;
  bool _allowLocation = true;
  bool _allowBreakingNews = true;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _loadOnboardingState();
  }

  Future<void> _loadOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_complete') ?? false;
    if (completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      });
      return;
    }
    if (!mounted) return;
    setState(() => _isChecking = false);
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setBool('allow_notifications', _allowNotifications);
    await prefs.setBool('allow_location', _allowLocation);
    await prefs.setBool('allow_breaking_news', _allowBreakingNews);

    if (_allowNotifications) {
      await PermissionService.requestNotificationPermission();
      await NotificationService.initialize();
    }

    if (_allowLocation) {
      await PermissionService.requestLocationPermission();
    }

    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    });
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.secondaryBorder),
        boxShadow: AppShadows.smallList,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.lightRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.chowkOrange, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppTheme.chowkOrange,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kagazWhite,
      body: SafeArea(
        child: _isChecking
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 110,
                              width: 110,
                              decoration: BoxDecoration(
                                color: AppTheme.white,
                                shape: BoxShape.circle,
                                boxShadow: AppShadows.mediumList,
                              ),
                              child: Center(
                                child: ChowkLogo(
                                  size: 26,
                                  spacing: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          ChowkLogo(
                            size: 32,
                            spacing: 10,
                            textStyle: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: AppTheme.chowkBlack,
                                  letterSpacing: -1.2,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'हर खबर, हर पन्ना, सबसे पहले',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppTheme.chowkBlack,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'पहले घर पर ही CHOWK से जुड़े. ये स्क्रीन आपको लाइव अपडेट, शहर की खबर और ब्रेकिंग अलर्ट तुरंत देता है।',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          _buildPermissionTile(
                            icon: Icons.notifications_active_rounded,
                            title: 'ब्रेकिंग अलर्ट',
                            subtitle: 'तुरंत लाइव अपडेट और अहम खबरें सीधे आपके फोन पर।',
                            value: _allowNotifications,
                            onChanged: (value) => setState(() => _allowNotifications = value),
                          ),
                          _buildPermissionTile(
                            icon: Icons.location_on_rounded,
                            title: 'अपना शहर',
                            subtitle: 'अपने इलाके की खास खबरें और स्थानीय रिपोर्टिंग के लिए।',
                            value: _allowLocation,
                            onChanged: (value) => setState(() => _allowLocation = value),
                          ),
                          _buildPermissionTile(
                            icon: Icons.flash_on_rounded,
                            title: 'लाइव रिपोर्टिंग',
                            subtitle: 'रियल-टाइम ब्रेकिंग समाचार और रिपोर्ट्स के लिये।',
                            value: _allowBreakingNews,
                            onChanged: (value) => setState(() => _allowBreakingNews = value),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.secondaryBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('क्या होगा अगर आप आगे बढ़ते हैं?', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 12),
                                _buildBenefitRow('लाइव ब्रेकिंग न्यूज तुरंत मिलती है', Icons.flash_on_rounded),
                                const SizedBox(height: 10),
                                _buildBenefitRow('आपके शहर से जुड़े अपडेट', Icons.location_city_rounded),
                                const SizedBox(height: 10),
                                _buildBenefitRow('पर्सनलाइज़्ड हेडलाइन्स', Icons.person_rounded),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: ElevatedButton(
                      onPressed: _completeOnboarding,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('शुरू करें'),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBenefitRow(String label, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.lightRed,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.chowkOrange, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
