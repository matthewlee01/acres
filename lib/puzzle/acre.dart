import 'package:acres/puzzle/position.dart';
import 'package:equatable/equatable.dart';

enum AcreType { open, closed, empty }

class Acre extends Equatable {
  const Acre({required this.position, required this.type});

  final Position position;
  final AcreType type;

  // overrides toString with props
  @override
  bool get stringify => true;

  @override
  List<Object> get props => [position, type];
}
