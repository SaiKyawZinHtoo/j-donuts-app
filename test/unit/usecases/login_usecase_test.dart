import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  test('LoginUseCase delegates to repository.login', () async {
    final repo = MockAuthRepository();
    final testUser = AuthUser(
      id: '1',
      phone: '+959254135592',
      firstName: 'Ye',
      lastName: 'Lin',
      dob: DateTime(2000, 1, 1),
    );
    when(() => repo.login('+959254135592'))
        .thenAnswer((_) async => Result.ok(testUser));
    final result = await LoginUseCase(repo).call('+959254135592');
    expect(result, isA<Ok<AuthUser>>());
  });
}
