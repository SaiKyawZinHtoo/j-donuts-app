import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';

void main() {
  group('validateOtp', () {
    test('accepts exactly 123456', () => expect(validateOtp('123456'), isA<ValidationValid>()));
    test('rejects any other 6 digits', () => expect(validateOtp('111111'), isA<ValidationInvalid>()));
  });
}
