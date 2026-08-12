import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_news/core/theme/app_theme.dart';
import 'package:e_news/core/routes/app_routes.dart';
import 'package:e_news/data/repositories/providers.dart';
import 'package:e_news/presentation/widgets/auth_modal.dart';
import 'package:e_news/presentation/widgets/premium_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isEditMode = false;

  final TextEditingController _nameController = TextEditingController(
    text: 'राज कुमार',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'raj.kumar@example.com',
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppTheme.softWhite,
        appBar: AppBar(
          title: const Text('प्रोफाइल'),
          backgroundColor: AppTheme.white,
          foregroundColor: AppTheme.chowkBlack,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'आप पहले लॉगिन करें।',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.chowkOrange),
                  onPressed: () => showAuthModal(context),
                  child: const Text('लॉगिन करें'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            boxShadow: AppShadows.mediumList,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'प्रोफाइल',
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.lightRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() => _isEditMode = !_isEditMode);
                    },
                    icon: Icon(
                      _isEditMode ? Icons.close : Icons.edit,
                      color: AppTheme.primaryRed,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 30),

            if (!_isEditMode) ...[
              // Stats
              _buildStatsSection(),
              const SizedBox(height: 30),

              // Quick Actions
              _buildQuickActionsSection(),
              const SizedBox(height: 30),

              // Settings
              _buildSettingsSection(),
            ] else ...[
              // Edit Profile Form
              _buildEditProfileForm(),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppTheme.primaryRed, AppTheme.darkRed],
              ),
              boxShadow: AppShadows.largeList,
            ),
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text('राज कुमार', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'raj.kumar@example.com',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.lightRed,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'प्रीमियम सदस्य',
              style: TextStyle(
                color: AppTheme.primaryRed,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCard('324', 'पढ़े गए समाचार'),
          const SizedBox(width: 12),
          _buildStatCard('48', 'सहेजे गए समाचार'),
          const SizedBox(width: 12),
          _buildStatCard('12', 'फॉलोइंग'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppShadows.mediumList,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppTheme.primaryRed),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('क्विक लिंक्स', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildActionTile(
            icon: Icons.bookmark,
            title: 'सहेजे गए समाचार',
            subtitle: 'आपके पसंदीदा समाचार देखें',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildActionTile(
            icon: Icons.history,
            title: 'पढ़ने का इतिहास',
            subtitle: 'हाल ही में पढ़े गए समाचार',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildActionTile(
            icon: Icons.notifications,
            title: 'सूचनाएं',
            subtitle: 'सूचना प्राथमिकताएं प्रबंधित करें',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildActionTile(
            icon: Icons.upload_file,
            title: 'न्यूज़ अपलोड करें',
            subtitle: 'एडमिन के रूप में नया समाचार जोड़ें',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.adminUpload);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.mediumGray),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.lightRed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryRed),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkBase,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: AppTheme.lightText),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('सेटिंग्स', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'भाषा',
            value: 'हिंदी',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            icon: Icons.dark_mode,
            title: 'थीम',
            value: 'लाइट मोड',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'गोपनीयता नीति',
            value: '',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            icon: Icons.help,
            title: 'सहायता और प्रतिक्रिया',
            value: '',
            onTap: () {},
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // Logout logic
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('लॉगआउट'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.mediumGray),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.mutedText),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkBase,
                ),
              ),
            ),
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.mutedText,
                ),
              ),
            const Icon(Icons.arrow_forward, color: AppTheme.lightText),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'प्रोफाइल संपादित करें',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          _buildLabel('नाम'),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.lightGray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.mediumGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.mediumGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryRed,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLabel('ईमेल'),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.lightGray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.mediumGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.mediumGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryRed,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _isEditMode = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('प्रोफाइल अपडेट हुई!'),
                    backgroundColor: AppTheme.accentGreen,
                  ),
                );
              },
              child: const Text('परिवर्तन सहेजें'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppTheme.darkBase,
      ),
    );
  }
}
