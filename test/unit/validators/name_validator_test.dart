import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';

void main() {
  group('validateFirstName', () {
    test(
      'rejects empty string',
      () => expect(validateFirstName(''), isA<ValidationInvalid>()),
    );
    test(
      'accepts Myanmar script name',
      () => expect(validateFirstName('မျိုးသူ'), isA<ValidationValid>()),
    );
    test(
      'rejects digits',
      () => expect(validateFirstName('Ye123'), isA<ValidationInvalid>()),
    );
  });

  group('validateFirstName extra', () {
    test('accepts 50 chars, rejects 51', () {
      expect(validateFirstName('a' * 50), isA<ValidationValid>());
      expect(validateFirstName('a' * 51), isA<ValidationInvalid>());
    });
    test('trims before counting; whitespace-only is empty', () {
      expect(validateFirstName('  ${'a' * 50}  '), isA<ValidationValid>());
      expect(validateFirstName('   '), isA<ValidationInvalid>());
    });
    test('accepts spaces inside', () {
      expect(validateFirstName('Mary Ann'), isA<ValidationValid>());
    });
    test('rejects Myanmar digits', () {
      expect(validateFirstName('မျိုး၁၂၃'), isA<ValidationInvalid>());
    });
    test('rejects punctuation', () {
      expect(validateFirstName('Ye-Lin'), isA<ValidationInvalid>());
    });
  });

  group('validateLastName', () {
    test('rejects 51 chars and Myanmar digits', () {
      expect(validateLastName('a' * 51), isA<ValidationInvalid>());
      expect(validateLastName('၅'), isA<ValidationInvalid>());
    });
    test(
      'accepts empty string',
      () => expect(validateLastName(''), isA<ValidationValid>()),
    );
    test(
      'rejects digits',
      () => expect(validateLastName('Lin99'), isA<ValidationInvalid>()),
    );
    test(
      'accepts normal name',
      () => expect(validateLastName('Lin'), isA<ValidationValid>()),
    );
  });
}
