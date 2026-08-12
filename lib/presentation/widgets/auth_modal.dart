import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/providers.dart';
import '../../core/routes/app_routes.dart';

class AuthModal extends StatefulWidget {
  const AuthModal({super.key});

  @override
  State<AuthModal> createState() => _AuthModalState();
}

void showAuthModal(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => const Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: AuthModal(),
    ),
  );
}

class _AuthModalState extends State<AuthModal> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.softWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppShadows.large],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('लॉगिन'),
                  selected: _isLogin,
                  onSelected: (v) => setState(() => _isLogin = true),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('रजिस्टर'),
                  selected: !_isLogin,
                  onSelected: (v) => setState(() => _isLogin = false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  if (!_isLogin)
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(hintText: 'पूरा नाम'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'नाम आवश्यक है' : null,
                    ),
                  if (!_isLogin) const SizedBox(height: 8),
                  if (!_isLogin)
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(hintText: 'शहर (वैकल्पिक)'),
                    ),
                  if (!_isLogin) const SizedBox(height: 8),
                  if (!_isLogin)
                    TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(hintText: 'राज्य (वैकल्पिक)'),
                    ),
                  if (!_isLogin) const SizedBox(height: 8),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(hintText: 'ईमेल'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || !v.contains('@') ? 'वैध ईमेल दें' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(hintText: 'पासवर्ड'),
                    obscureText: true,
                    validator: (v) => v == null || v.length < 6 ? 'कम से कम 6 वर्ण' : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _submit(auth),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_isLogin ? 'लॉगिन करें' : 'रजिस्टर करें'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Admin quick login: admin@chowk.local / Chowk@12345',
              style: TextStyle(color: AppTheme.mutedText, fontSize: 12),
            ),
            const SizedBox(height: 8),
            const Text(
              'सामान्य रजिस्ट्रेशन subscriber खाते के रूप में होता है। एडमिन ही reporter/editor/publisher/moderator/admin भूमिका दे सकते हैं।',
              style: TextStyle(color: AppTheme.mutedText, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        setState(() => _isLoading = true);
                        final navigator = Navigator.of(context);
                        final ok = await auth.login(email: 'admin@chowk.local', password: 'Chowk@12345');
                        setState(() => _isLoading = false);
                        if (ok) {
                          if (!mounted) return;
                          navigator.pop();
                          navigator.pushReplacementNamed(auth.isAdmin ? AppRoutes.adminDashboard : AppRoutes.home);
                        }
                      },
                      child: const Text('Admin'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        setState(() => _isLoading = true);
                        final navigator = Navigator.of(context);
                        final ok = await auth.login(email: 'superadmin@enews.com', password: 'Admin123!');
                        setState(() => _isLoading = false);
                        if (ok) {
                          if (!mounted) return;
                          navigator.pop();
                          navigator.pushReplacementNamed(auth.isAdmin ? AppRoutes.adminDashboard : AppRoutes.home);
                        }
                      },
                      child: const Text('Super Admin'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('बंद करें'),
              ),
          ],
        ),
      ),
    ),
  );
  }

  Future<void> _submit(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    bool ok = false;
    if (_isLogin) {
      ok = await auth.login(email: email, password: password);
    } else {
      final name = _nameController.text.trim();
      ok = await auth.register(
        name: name,
        email: email,
        password: password,
        city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
        state: _stateController.text.trim().isNotEmpty ? _stateController.text.trim() : null,
      );
    }

    setState(() => _isLoading = false);

    if (ok) {
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed(auth.isAdmin ? AppRoutes.adminDashboard : AppRoutes.home);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLogin ? 'लॉगिन सफल' : 'रजिस्ट्रेशन सफल। आपका खाता subscriber के रूप में बनाया गया है।'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'त्रुटि'), backgroundColor: Colors.red));
      }
    }
  }
}
