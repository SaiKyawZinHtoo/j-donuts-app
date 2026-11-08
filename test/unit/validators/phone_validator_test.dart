import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';

void main() {
  group('validatePhone', () {
    test('accepts 09254135592 and normalizes to +959254135592', () {
      expect(validatePhone('09254135592'), isA<ValidationValid>());
    });
    test('rejects fewer than 7 digits after prefix', () {
      expect(validatePhone('091234'), isA<ValidationInvalid>());
    });
    test('rejects more than 9 digits after prefix', () {
      expect(validatePhone('0123456789012'), isA<ValidationInvalid>());
    });
    test('rejects a number not starting with 9 after the prefix', () {
      expect(validatePhone('08254135592'), isA<ValidationInvalid>());
    });
    test('rejects only 6 digits after the leading 9', () {
      expect(validatePhone('0912345'), isA<ValidationInvalid>());
    });
    test('rejects 10 digits after the leading 9', () {
      expect(validatePhone('091234567890'), isA<ValidationInvalid>());
    });
  });
}
