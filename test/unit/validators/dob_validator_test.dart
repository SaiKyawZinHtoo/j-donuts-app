import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';

void main() {
  group('validateDob', () {
    test('rejects Feb 29 in a non-leap year', () {
      expect(validateDob(DateTime(2023, 2, 29)), isA<ValidationInvalid>());
    });
    test('accepts Feb 29 in a leap year', () {
      expect(validateDob(DateTime(2000, 2, 29)), isA<ValidationValid>());
    });
    test('accepts today minus 13 years only; today is invalid', () {
      final n = DateTime.now();
      expect(validateDob(DateTime(n.year, n.month, n.day)),
          isA<ValidationInvalid>());
    });
    test('rejects a date in the future (tomorrow)', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(validateDob(tomorrow), isA<ValidationInvalid>());
    });
    test('accepts someone whose 13th birthday is today', () {
      final now = DateTime.now();
      final thirteenthBirthday = DateTime(now.year - 13, now.month, now.day);
      expect(validateDob(thirteenthBirthday), isA<ValidationValid>());
    });
    test('rejects someone one day short of 13', () {
      final now = DateTime.now();
      final oneDayShort = DateTime(
        now.year - 13,
        now.month,
        now.day,
      ).add(const Duration(days: 1));
      expect(validateDob(oneDayShort), isA<ValidationInvalid>());
    });
  });
}
