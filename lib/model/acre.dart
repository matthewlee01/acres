import 'package:acres/model/position.dart';
import 'package:rive/rive.dart';

enum AcreType {
  empty,
  source,
  trb,
  rbl,
  tbl,
  trl,
  trbl,
  tb,
  rl,
  tr,
  rb,
  bl,
  tl,
}

extension ParseToString on AcreType {
  String toShortString() {
    return toString().split('.').last;
  }
}

class Acre {
  Position position;
  final AcreType type;
  bool saturating;
  bool saturated = false;

  final bool openT;
  final bool openR;
  final bool openB;
  final bool openL;

  SMIBool? flowT;
  SMIBool? flowR;
  SMIBool? flowB;
  SMIBool? flowL;
  SMIBool? flowS;

  final int id;

  Acre({
    required this.position,
    required this.type,
    required this.id,
    this.saturating = false,
  })  : openT = (type == AcreType.tb ||
            type == AcreType.tr ||
            type == AcreType.tl ||
            type == AcreType.trb ||
            type == AcreType.tbl ||
            type == AcreType.trl ||
            type == AcreType.trbl ||
            type == AcreType.source),
        openR = (type == AcreType.rl ||
            type == AcreType.tr ||
            type == AcreType.rb ||
            type == AcreType.trb ||
            type == AcreType.rbl ||
            type == AcreType.trl ||
            type == AcreType.trbl ||
            type == AcreType.source),
        openB = (type == AcreType.tb ||
            type == AcreType.rb ||
            type == AcreType.bl ||
            type == AcreType.trb ||
            type == AcreType.rbl ||
            type == AcreType.tbl ||
            type == AcreType.trbl ||
            type == AcreType.source),
        openL = (type == AcreType.rl ||
            type == AcreType.bl ||
            type == AcreType.tl ||
            type == AcreType.rbl ||
            type == AcreType.tbl ||
            type == AcreType.trl ||
            type == AcreType.trbl ||
            type == AcreType.source);

  @override
  String toString() {
    return type.toShortString().toUpperCase() +
        "\n" +
        position.toString() +
        saturating.toString() +
        saturated.toString() +
        " " +
        flowT!.value.toString() +
        flowR!.value.toString() +
        flowB!.value.toString() +
        flowL!.value.toString() +
        flowS!.value.toString();
  }

  Acre copyWith({Position? newP, AcreType? newT, bool? newS}) {
    return Acre(
      id: id,
      position: newP ?? position,
      type: newT ?? type,
      saturating: newS ?? saturating,
    );
  }
}
