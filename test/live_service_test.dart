import 'package:flutter_test/flutter_test.dart';
import 'package:e_news/services/live_service.dart';

void main() {
  group('LiveService payload parsing', () {
    test('parses a string payload into a map', () {
      final result = LiveService.instance.parseIncomingUpdate('{"id":1,"title":"Test"}');

      expect(result['id'], 1);
      expect(result['title'], 'Test');
    });

    test('returns a copy of a map payload', () {
      final input = {'id': 2, 'title': 'Hello'};
      final result = LiveService.instance.parseIncomingUpdate(input);

      expect(result['id'], 2);
      expect(result['title'], 'Hello');
    });
  });
}
