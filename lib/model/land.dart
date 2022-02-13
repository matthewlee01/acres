import 'package:flutter/material.dart';
import 'package:acres/model/acre.dart';
import 'package:acres/model/position.dart';
import 'package:rive/rive.dart';

const double landWidth = 350;
const double landHeight = 350;

class Land extends StatefulWidget {
  const Land({
    Key? key,
    required this.size,
  }) : super(key: key);

  final int size;

  @override
  _LandState createState() => _LandState();
}

class _LandState extends State<Land> {
  late List<Acre> _acres;
  late Position emptyPos;

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    _acres = generateAcres(widget.size);
    irrigate();
  }

  // generates initial list of acres
  List<Acre> generateAcres(int size) {
    List<Acre> acres = [];
    acres.add(Acre(
      id: 0,
      position: const Position(
        x: 0,
        y: 0,
      ),
      type: AcreType.source,
    ));
    acres[0].saturated = true;
    for (int i = 1; i < (size * size) - 1; i++) {
      acres.add(
        Acre(
            id: i,
            position: Position(
              x: i % size,
              y: i ~/ size,
            ),
            type: AcreType.values[(i % (AcreType.values.length - 2)) + 1]),
      );
    }
    acres.add(
      Acre(
        id: (size * size - 1),
        position: Position(
          x: size - 1,
          y: size - 1,
        ),
        type: AcreType.empty,
      ),
    );
    emptyPos = Position(x: size - 1, y: size - 1);
    return acres;
  }

  // converts pos to index
  int _posToIndex(Position p) {
    return p.x + p.y * widget.size;
  }

  // converts pos to acre
  Acre _posToAcre(Position p) {
    return _acres[_posToIndex(p)];
  }

  // checks if current acre is slideable
  bool _acreSlideable(Acre acre) {
    return (acre.position.x == emptyPos.x || acre.position.y == emptyPos.y);
  }

  // slides tiles into empty space if possible
  void _slideAcres(Acre acre) {
    if (acre.type == AcreType.empty || !_acreSlideable(acre)) return;
    Position targetEmpty = acre.position;
    Acre empty = _posToAcre(emptyPos);
    int dx = (acre.position.x - emptyPos.x).sign;
    int dy = (acre.position.y - emptyPos.y).sign;

    setState(() {
      while (emptyPos != targetEmpty) {
        Position swapP = Position(x: emptyPos.x + dx, y: emptyPos.y + dy);
        Acre swap = _posToAcre(swapP);
        empty.position = swapP;
        swap.position = emptyPos;
        _acres[_posToIndex(swapP)] = empty;
        _acres[_posToIndex(emptyPos)] = swap;
        emptyPos = swapP;
      }
    });
  }

  // checks if an acre is saturated by its neighbours
  // returns a list of bools corresponding to T,R,B,L
  List<bool> contiguous(Acre acre) {
    Position p = acre.position;
    return [
      (p.y > 0 &&
          acre.openT &&
          _posToAcre(Position(x: p.x, y: p.y - 1)).openB &&
          _posToAcre(Position(x: p.x, y: p.y - 1)).saturated &&
          _posToAcre(Position(x: p.x, y: p.y - 1)).saturating),
      (p.x < widget.size - 1 &&
          acre.openR &&
          _posToAcre(Position(x: p.x + 1, y: p.y)).openL &&
          _posToAcre(Position(x: p.x + 1, y: p.y)).saturated &&
          _posToAcre(Position(x: p.x + 1, y: p.y)).saturating),
      (p.y < widget.size - 1 &&
          acre.openB &&
          _posToAcre(Position(x: p.x, y: p.y + 1)).openT &&
          _posToAcre(Position(x: p.x, y: p.y + 1)).saturated &&
          _posToAcre(Position(x: p.x, y: p.y + 1)).saturating),
      (p.x > 0 &&
          acre.openL &&
          _posToAcre(Position(x: p.x - 1, y: p.y)).openR &&
          _posToAcre(Position(x: p.x - 1, y: p.y)).saturated &&
          _posToAcre(Position(x: p.x - 1, y: p.y)).saturating),
    ];
  }

  // clears saturating status from all acres
  void drain() {
    for (int i = 0; i < _acres.length; i++) {
      if (_acres[i].type != AcreType.source) {
        _acres[i].saturating = false;
        _acres[i].flowT?.value = false;
        _acres[i].flowR?.value = false;
        _acres[i].flowB?.value = false;
        _acres[i].flowL?.value = false;
      }
    }
  }

  // saturates acres
  void irrigate() {
    // iterate, recurse if contiguous and not already saturated
    for (int i = 0; i < _acres.length; i++) {
      Acre acre = _acres[i];
      if ((acre.type == AcreType.source || contiguous(acre).contains(true)) &&
          acre.saturating == false) {
        setState(() {
          _acres[i].saturating = true;
        });
        irrigate();
      }
    }
  }

  void setFlows() {
    for (int i = 0; i < _acres.length; i++) {
      var contiguity = contiguous(_acres[i]);
      _acres[i].flowT?.value = contiguity[0];
      _acres[i].flowR?.value = contiguity[1];
      _acres[i].flowB?.value = contiguity[2];
      _acres[i].flowL?.value = contiguity[3];
    }
  }

  bool fullySaturated() {
    for (int i = 0; i < _acres.length; i++) {
      if (!_acres[i].saturated) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _acres.map((acre) {
        return AnimatedPositioned(
            key: ValueKey(acre.id),
            left: acre.position.x * (landWidth / widget.size),
            top: acre.position.y * (landHeight / widget.size),
            width: landWidth / widget.size,
            height: landHeight / widget.size,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
            onEnd: () {
              setState(() {
                drain();
                irrigate();
                setFlows();
              });
            },
            child: (acre.type != AcreType.empty)
                ? GestureDetector(
                    onTap: () {
                      _slideAcres(acre);
                    },
                    onLongPress: () {
                      // ignore: avoid_print
                      print(acre);
                    },
                    child: RiveAnimation.asset(
                      'assets/acres.riv',
                      fit: BoxFit.cover,
                      stateMachines: const ['flows'],
                      artboard: acre.type.toShortString(),
                      onInit: (Artboard artboard) {
                        {
                          final controller =
                              StateMachineController.fromArtboard(
                            artboard,
                            'flows',
                            onStateChange: (_, state) {
                              setState(
                                () {
                                  if (state == 'full') {
                                    acre.saturated = true;
                                  } else if (!acre.saturating) {
                                    acre.saturated = false;
                                  }
                                  irrigate();
                                  setFlows();
                                },
                              );
                            },
                          );
                          artboard.addController(controller!);
                          List<bool> contiguity = contiguous(acre);
                          acre.flowT = controller.findInput<bool>('topFlowing')
                              as SMIBool;
                          acre.flowT?.value = contiguity[0];
                          acre.flowR = controller
                              .findInput<bool>('rightFlowing') as SMIBool;
                          acre.flowR?.value = contiguity[1];

                          acre.flowB = controller
                              .findInput<bool>('bottomFlowing') as SMIBool;
                          acre.flowB?.value = contiguity[2];

                          acre.flowL = controller.findInput<bool>('leftFlowing')
                              as SMIBool;
                          acre.flowL?.value = contiguity[3];
                        }
                      },
                    ),
                  )
                : Container());
      }).toList(),
    );
  }
}
