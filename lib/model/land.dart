import 'dart:math';
import 'package:flutter/material.dart';
import 'package:acres/model/acre.dart';
import 'package:acres/model/position.dart';
import 'package:rive/rive.dart';
import 'package:acres/globals.dart' as globals;

const double maxLength = 500;

class Land extends StatefulWidget {
  const Land({
    Key? key,
  }) : super(key: key);

  @override
  _LandState createState() => _LandState();
}

class _LandState extends State<Land> {
  late List<Acre> _acres;
  late Position emptyPos;
  int size = 3;
  double haloSpread = 0;
  double landOpacity = 0.0;
  bool tilesLocked = false;

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    _acres = generateAcres(size);
    Future.delayed(Duration.zero, () async {
      setState(() {
        landOpacity = 1.0;
      });
    });
  }

  // generates initial list of acres
  List<Acre> generateAcres(int size) {
    // generate list of types
    List<AcreType> types = [AcreType.empty];
    int sourceCount = ((size - 3) ~/ 2) + 1;
    for (int i = 0; i < sourceCount; i++) {
      types.add(AcreType.source);
    }
    for (int i = 0; i < (size * size) - (sourceCount + 1); i++) {
      int idx = (i % (AcreType.values.length - 2)) + 2;
      types.add(AcreType.values[idx]);
    }

    // shuffle types
    types.shuffle();

    // generate acres from types
    List<Acre> acres = [];
    for (int i = 0; i < types.length; i++) {
      if (types[i] == AcreType.empty) {
        emptyPos = Position(x: i % size, y: i ~/ size);
      }
      acres.add(Acre(
        id: i,
        position: Position(
          x: i % size,
          y: i ~/ size,
        ),
        type: types[i],
      ));
    }
    return acres;
  }

  // converts pos to index
  int _posToIndex(Position p) {
    return p.x + p.y * size;
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
      (p.x < size - 1 &&
          acre.openR &&
          _posToAcre(Position(x: p.x + 1, y: p.y)).openL &&
          _posToAcre(Position(x: p.x + 1, y: p.y)).saturated &&
          _posToAcre(Position(x: p.x + 1, y: p.y)).saturating),
      (p.y < size - 1 &&
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
    for (Acre acre in _acres) {
      if (acre.type != AcreType.source) {
        acre.saturating = false;
        acre.flowT?.value = false;
        acre.flowR?.value = false;
        acre.flowB?.value = false;
        acre.flowL?.value = false;
      }
    }
  }

  // saturates acres
  void irrigate() {
    // iterate, recurse if contiguous and not already saturated
    for (Acre acre in _acres) {
      if ((acre.type == AcreType.source || contiguous(acre).contains(true)) &&
          acre.saturating == false) {
        setState(() {
          acre.saturating = true;
        });
        irrigate();
      }
    }
  }

  void setFlows() {
    for (Acre acre in _acres) {
      var contiguity = contiguous(acre);
      acre.flowT?.value = contiguity[0];
      acre.flowR?.value = contiguity[1];
      acre.flowB?.value = contiguity[2];
      acre.flowL?.value = contiguity[3];
      acre.flowS?.value = acre.saturating;
    }
  }

  bool fullySaturated() {
    for (Acre acre in _acres) {
      if (!acre.saturated && acre.type != AcreType.empty) {
        return false;
      }
    }
    return true;
  }

  void endLevel() {
    setState(() {
      haloSpread = 15.0;
      tilesLocked = true;
    });
  }

  void transitionLevel() {
    setState(() {
      size++;
      landOpacity = 1.0;
      _acres = generateAcres(size);
      tilesLocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size window = MediaQuery.of(context).size;
    double length = min(
        min(window.width, window.height - globals.menuHeight) * 0.9, maxLength);
    return SizedBox(
      width: length,
      height: length,
      child: AnimatedContainer(
        duration: const Duration(seconds: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(255, 250, 125, 100),
              blurRadius: haloSpread,
              spreadRadius: haloSpread,
            ),
            const BoxShadow(
              color: globals.darkGreen,
              spreadRadius: 5.0,
            )
          ],
        ),
        onEnd: () {
          if (haloSpread > 0.0) {
            setState(() {
              landOpacity = 0.0;
              haloSpread = 0.0;
            });
          } else if (haloSpread == 0 && landOpacity == 0.0) {
            transitionLevel();
          }
        },
        child: AnimatedOpacity(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInExpo,
          opacity: landOpacity,
          child: Stack(
            key: ValueKey(size),
            children: _acres.map((acre) {
              return AnimatedPositioned(
                  key: ValueKey(acre.id),
                  left: (acre.position.x * (length / size)).ceilToDouble(),
                  top: (acre.position.y * (length / size)).ceilToDouble(),
                  width: (length / size).ceilToDouble(),
                  height: (length / size).ceilToDouble(),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                  onEnd: () {
                    setState(() {
                      drain();
                      irrigate();
                      setFlows();
                      if (fullySaturated()) {
                        endLevel();
                      }
                    });
                  },
                  child: (acre.type != AcreType.empty)
                      ? GestureDetector(
                          onTap: () {
                            if (!tilesLocked) {
                              _slideAcres(acre);
                            }
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
                                        if (fullySaturated()) {
                                          endLevel();
                                        }
                                      },
                                    );
                                  },
                                );
                                artboard.addController(controller!);
                                List<bool> contiguity = contiguous(acre);
                                acre.flowT = controller
                                    .findInput<bool>('topFlowing') as SMIBool;
                                acre.flowT?.value = contiguity[0];
                                acre.flowR = controller
                                    .findInput<bool>('rightFlowing') as SMIBool;
                                acre.flowR?.value = contiguity[1];

                                acre.flowB =
                                    controller.findInput<bool>('bottomFlowing')
                                        as SMIBool;
                                acre.flowB?.value = contiguity[2];
                                acre.flowL = controller
                                    .findInput<bool>('leftFlowing') as SMIBool;
                                acre.flowL?.value = contiguity[3];
                                acre.flowS = controller
                                    .findInput<bool>('saturating') as SMIBool;
                                acre.flowS?.value = false;
                              }
                            },
                          ),
                        )
                      : Container());
            }).toList(),
          ),
        ),
      ),
    );
  }
}
