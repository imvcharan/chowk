import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/providers.dart';
import 'auth_modal.dart';

class AuthEntryButton extends StatelessWidget {
  const AuthEntryButton({super.key, this.isLoggedIn = false});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    final auth = context.select<AuthProvider, bool>((provider) => provider.isLoggedIn);
    final username = context.select<AuthProvider, String?>((provider) => provider.username);
    final loggedIn = isLoggedIn || auth;
    final displayName = (username ?? '').trim();
    final initials = displayName.isEmpty
        ? 'U'
        : displayName.split(RegExp(r'\s+')).take(2).map((part) => part.isNotEmpty ? part[0] : '').join().toUpperCase();

    return GestureDetector(
      onTap: () {
        if (loggedIn) {
          Navigator.of(context).pushNamed(AppRoutes.profile);
        } else {
          showAuthModal(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: loggedIn ? AppTheme.white : AppTheme.lightRed,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: loggedIn ? AppTheme.secondaryBorder : AppTheme.primaryRed.withOpacity(0.16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loggedIn)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryRed,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            else
              Icon(
                Icons.login_rounded,
                size: 18,
                color: AppTheme.primaryRed,
              ),
            const SizedBox(width: 6),
            Text(
              loggedIn
                  ? (displayName.isNotEmpty ? displayName : 'प्रोफाइल')
                  : 'लॉगिन',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: loggedIn ? AppTheme.chowkBlack : AppTheme.primaryRed,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
