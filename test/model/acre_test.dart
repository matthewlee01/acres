import 'package:flutter_test/flutter_test.dart';
import 'package:acres/model/position.dart';
import 'package:acres/model/acre.dart';

void main() {
  const testX = 2;
  const testY = 2;
  const p = Position(x: testX, y: testY);
  const a = Acre(position: p, type: AcreType.open);

  test('constructer should set proper values', () {
    expect(a.position.x, testX);
    expect(a.position.y, testY);
    expect(a.type, AcreType.open);
  });
}
