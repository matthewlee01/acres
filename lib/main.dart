import 'package:flutter/material.dart';
import 'package:acres/model/acre.dart';
import 'package:acres/model/position.dart';

const double landWidth = 350;
const double landHeight = 350;
void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  static const size = 4;
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'acres',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const Center(
        child: SizedBox(
          width: landWidth,
          height: landHeight,
          child: AspectRatio(
            aspectRatio: 1,
            child: Land(
              size: size,
            ),
          ),
        ),
      ),
    );
  }
}

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
  bool contiguous(Acre acre) {
    Position p = acre.position;
    return ((p.x > 0 &&
            acre.openL &&
            _posToAcre(Position(x: p.x - 1, y: p.y)).openR &&
            _posToAcre(Position(x: p.x - 1, y: p.y)).saturated &&
            _posToAcre(Position(x: p.x - 1, y: p.y)).saturating) ||
        (p.x < widget.size - 1 &&
            acre.openR &&
            _posToAcre(Position(x: p.x + 1, y: p.y)).openL &&
            _posToAcre(Position(x: p.x + 1, y: p.y)).saturated &&
            _posToAcre(Position(x: p.x + 1, y: p.y)).saturating) ||
        (p.y > 0 &&
            acre.openT &&
            _posToAcre(Position(x: p.x, y: p.y - 1)).openB &&
            _posToAcre(Position(x: p.x, y: p.y - 1)).saturated &&
            _posToAcre(Position(x: p.x, y: p.y - 1)).saturating) ||
        (p.y < widget.size - 1 &&
            acre.openB &&
            _posToAcre(Position(x: p.x, y: p.y + 1)).openT &&
            _posToAcre(Position(x: p.x, y: p.y + 1)).saturated &&
            _posToAcre(Position(x: p.x, y: p.y + 1)).saturating));
  }

  // clears saturating status from all acres
  void drain() {
    for (int i = 0; i < _acres.length; i++) {
      if (_acres[i].type != AcreType.source) {
        _acres[i].saturating = false;
      }
    }
  }

  // saturates acres
  void irrigate() {
    // iterate, recurse if contiguous and not already saturated
    for (int i = 0; i < _acres.length; i++) {
      Acre acre = _acres[i];
      if ((acre.type == AcreType.source || contiguous(acre)) &&
          acre.saturating == false) {
        setState(() {
          _acres[i].saturating = true;
        });
        irrigate();
      }
    }
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
            duration: const Duration(milliseconds: 420),
            curve: Curves.ease,
            onEnd: () {
              setState(() {
                drain();
                irrigate();
              });
            },
            child: (acre.type != AcreType.empty)
                ? AnimatedContainer(
                    duration: const Duration(milliseconds: 420),
                    onEnd: () {
                      setState(() {
                        acre.saturated = acre.saturating;
                        irrigate();
                      });
                    },
                    color:
                        acre.saturating ? Colors.green[100] : Colors.green[50],
                    child: TextButton(
                      onPressed: () {
                        _slideAcres(acre);
                      },
                      child: Text(acre.toString()),
                    ))
                : Container());
      }).toList(),
    );
  }
}
