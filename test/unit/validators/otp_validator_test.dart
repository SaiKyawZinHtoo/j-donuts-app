import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';

void main() {
  group('validateOtp', () {
    test(
      'accepts exactly 123456',
      () => expect(validateOtp('123456'), isA<ValidationValid>()),
    );
    test('rejects wrong length, letters and empty', () {
      expect(validateOtp('12345'), isA<ValidationInvalid>());
      expect(validateOtp('1234567'), isA<ValidationInvalid>());
      expect(validateOtp('12345a'), isA<ValidationInvalid>());
      expect(validateOtp(''), isA<ValidationInvalid>());
    });
    test(
      'rejects any other 6 digits',
      () => expect(validateOtp('111111'), isA<ValidationInvalid>()),
    );
  });
}
