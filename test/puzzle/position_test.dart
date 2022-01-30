import 'package:flutter_test/flutter_test.dart';
import 'package:acres/puzzle/position.dart';

void main() {
  const testX = 2;
  const testY = 2;
  const p = Position(x: testX, y: testY);

  test('constructer should set proper values', () {
    expect(p.x, testX);
    expect(p.y, testY);
  });
}
