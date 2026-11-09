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

  group('validateLastName', () {
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
