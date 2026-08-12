import 'package:flutter_test/flutter_test.dart';
import 'package:e_news/data/repositories/providers.dart';

void main() {
  group('AuthProvider role checks', () {
    test('treats super admin and admin roles as admin access', () {
      expect(AuthProvider.isAdminRole('super_admin'), isTrue);
      expect(AuthProvider.isAdminRole('admin'), isTrue);
    });

    test('treats subscriber and guest roles as non-admin access', () {
      expect(AuthProvider.isAdminRole('subscriber'), isFalse);
      expect(AuthProvider.isAdminRole(null), isFalse);
    });
  });
}
