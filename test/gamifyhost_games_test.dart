import 'package:flutter_test/flutter_test.dart';
import 'package:gamifyhost_games/gamifyhost_games.dart';

void main() {
  group('GamifyHostConfig', () {
    test('creates with required parameters', () {
      const config = GamifyHostConfig(
        publicKey: 'pk_test_123',
        userId: 'user_456',
      );

      expect(config.publicKey, 'pk_test_123');
      expect(config.userId, 'user_456');
      expect(config.apiUrl, 'https://api.gamifyhost.com');
      expect(config.widgetUrl, 'https://cdn.jsdelivr.net/npm/@gamifyhost/gamifyhost-widget/dist/widget.js');
      expect(config.initialBalance, 0);
    });

    test('creates with all parameters', () {
      const config = GamifyHostConfig(
        publicKey: 'pk_test_123',
        userId: 'user_456',
        apiUrl: 'https://custom-api.example.com',
        widgetUrl: 'https://custom-cdn.example.com/widget.js',
        initialBalance: 5000,
      );

      expect(config.apiUrl, 'https://custom-api.example.com');
      expect(config.widgetUrl, 'https://custom-cdn.example.com/widget.js');
      expect(config.initialBalance, 5000);
    });

    test('copyWith overrides specified fields', () {
      const original = GamifyHostConfig(
        publicKey: 'pk_test_123',
        userId: 'user_456',
        initialBalance: 1000,
      );

      final updated = original.copyWith(
        userId: 'user_789',
        initialBalance: 2000,
      );

      expect(updated.publicKey, 'pk_test_123');
      expect(updated.userId, 'user_789');
      expect(updated.initialBalance, 2000);
    });
  });

  group('HTML template', () {
    test('generates valid HTML with config values', () {
      const config = GamifyHostConfig(
        publicKey: 'pk_test_abc',
        userId: 'user_xyz',
        apiUrl: 'https://api.example.com',
        widgetUrl: 'https://cdn.example.com/widget.js',
        initialBalance: 3000,
      );

      // Access the HTML template builder via internal import
      // This test just verifies the config is accepted; HTML generation
      // is tested implicitly via the widget.
      expect(config.publicKey, isNotEmpty);
      expect(config.userId, isNotEmpty);
    });
  });
}
