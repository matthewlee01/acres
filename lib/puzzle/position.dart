import 'package:equatable/equatable.dart';

// 2d position of an element on a grid.
// (0, 0) is the top left corner of the plane.
class Position extends Equatable implements Comparable<Position> {
  const Position({required this.x, required this.y});

  final int x;
  final int y;

  // props for equality
  @override
  List<Object> get props => [x, y];

  // overrides toString with props
  @override
  bool get stringify => true;

  // compares two positions on *either* the x *or* y axis
  @override
  int compareTo(Position other) {
    if (y < other.y) {
      return -1;
    } else if (y > other.y) {
      return 1;
    } else {
      if (x < other.x) {
        return -1;
      } else if (x > other.x) {
        return 1;
      } else {
        return 0;
      }
    }
  }
}
