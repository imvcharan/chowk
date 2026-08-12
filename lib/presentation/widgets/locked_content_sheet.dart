import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'auth_modal.dart';

/// Bottom action sheet for limited content access
class LockedContentBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onRegisterPressed;
  final VoidCallback onLoginPressed;

  const LockedContentBottomSheet({
    super.key,
    this.title = 'पूरी खबर पढ़ें',
    this.description = 'इस खबर को पूरी तरह पढ़ने के लिए कृपया रजिस्टर करें या लॉगिन करें।',
    required this.onRegisterPressed,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.softWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.darkBase.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Lock icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline,
              color: AppTheme.primaryRed,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.darkBase,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.darkBase.withOpacity(0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Register button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onRegisterPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'नया खाता बनाएं',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.softWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Login button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: onLoginPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryRed, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'पहले से खाता है? लॉगिन करें',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Close button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'बंद करें',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.darkBase.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Show bottom sheet for locked content
void showLockedContentBottomSheet(
  BuildContext context, {
  String title = 'पूरी खबर पढ़ें',
  String description = 'इस खबर को पूरी तरह पढ़ने के लिए कृपया रजिस्टर करें या लॉगिन करें।',
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    builder: (context) => LockedContentBottomSheet(
      title: title,
      description: description,
      onRegisterPressed: () {
        Navigator.of(context).pop();
        showAuthModal(context);
      },
      onLoginPressed: () {
        Navigator.of(context).pop();
        showAuthModal(context);
      },
    ),
  );
}
