import 'package:flutter/material.dart';
import 'package:e_news/core/theme/app_theme.dart';

/// Dialog to remind users to register to view full content
class RegistrationReminderDialog extends StatelessWidget {
  final VoidCallback onRegisterPressed;
  final VoidCallback onLoginPressed;

  const RegistrationReminderDialog({
    super.key,
    required this.onRegisterPressed,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.softWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppShadows.large],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: 60,
              height: 60,
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
              'पूरी कहानी पढ़ें',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
                color: AppTheme.darkBase,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              'खबरों की पूरी जानकारी पाने के लिए रजिस्टर करें और बने हमारे समुदाय का हिस्सा',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.darkBase.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Features list
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _FeatureItem(
                    icon: Icons.star_outline,
                    text: 'सभी खबरें एक्सेस करें',
                  ),
                  const SizedBox(height: 12),
                  _FeatureItem(
                    icon: Icons.bookmark_outline,
                    text: 'अपने पसंदीदा खबरें सेव करें',
                  ),
                  const SizedBox(height: 12),
                  _FeatureItem(
                    icon: Icons.notifications_outlined,
                    text: 'महत्वपूर्ण खबरों की सूचनाएं पाएं',
                  ),
                ],
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
                  'अभी रजिस्टर करें',
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
                  'पहले से रजिस्टर हैं? लॉगिन करें',
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
                'अभी नहीं, धन्यवाद',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.darkBase.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Feature item for the registration reminder dialog
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryRed,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.darkBase,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Show registration reminder dialog
void showRegistrationReminder(
  BuildContext context, {
  required VoidCallback onRegisterPressed,
  required VoidCallback onLoginPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => RegistrationReminderDialog(
      onRegisterPressed: onRegisterPressed,
      onLoginPressed: onLoginPressed,
    ),
  );
}
