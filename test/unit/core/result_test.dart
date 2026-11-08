import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/result/result.dart';

void main() {
  test('Ok holds a value and Err holds a message', () {
    final ok = Result<int>.ok(5);
    final err = Result<int>.err('boom');
    expect(ok, isA<Ok<int>>());
    expect((ok as Ok<int>).value, 5);
    expect((err as Err<int>).message, 'boom');
  });
}
