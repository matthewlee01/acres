import 'package:acres/model/position.dart';
import 'package:equatable/equatable.dart';

enum AcreType {
  source,
  tb,
  rl,
  trbl,
  tr,
  rb,
  bl,
  tl,
  closed,
  empty,
}

class Acre extends Equatable {
  final Position position;
  final AcreType type;
  final bool saturation;

  final bool openT;
  final bool openR;
  final bool openB;
  final bool openL;

  const Acre({
    required this.position,
    required this.type,
    this.saturation = false,
  })  : openT = (type == AcreType.tb ||
            type == AcreType.tr ||
            type == AcreType.tl ||
            type == AcreType.trbl ||
            type == AcreType.source),
        openR = (type == AcreType.rl ||
            type == AcreType.tr ||
            type == AcreType.rb ||
            type == AcreType.trbl ||
            type == AcreType.source),
        openB = (type == AcreType.tb ||
            type == AcreType.rb ||
            type == AcreType.bl ||
            type == AcreType.trbl ||
            type == AcreType.source),
        openL = (type == AcreType.rl ||
            type == AcreType.bl ||
            type == AcreType.tl ||
            type == AcreType.trbl ||
            type == AcreType.source);

  // overrides toString with props
  @override
  bool get stringify => true;

  @override
  List<Object> get props => [
        position,
        type,
        saturation,
      ];

  Acre copyWith({Position? newP, AcreType? newT, bool? newS}) {
    return Acre(
      position: newP ?? position,
      type: newT ?? type,
      saturation: newS ?? saturation,
    );
  }
}
