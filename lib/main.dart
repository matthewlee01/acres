import 'package:flutter/material.dart';
import 'package:acres/model/acre.dart';
import 'package:acres/model/position.dart';

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
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.green),
      home: const Center(
        child: SizedBox(
          width: 500,
          height: 500,
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
  }

  List<Acre> generateAcres(int size) {
    List<Acre> acres = [];
    acres.add(Acre(
      position: const Position(
        x: 0,
        y: 0,
      ),
      type: AcreType.source,
    ));
    for (int i = 1; i < (size * size) - 1; i++) {
      acres.add(
        Acre(
            position: Position(
              x: i % size,
              y: i ~/ size,
            ),
            type: AcreType.values[(i % (AcreType.values.length - 2)) + 1]),
      );
    }
    acres.add(
      Acre(
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

  int _posToIndex(Position p) {
    return p.x + p.y * widget.size;
  }

  Acre _posToAcre(Position p) {
    return _acres[_posToIndex(p)];
  }

  bool _acreSlideable(Acre acre) {
    return (acre.position.x == emptyPos.x || acre.position.y == emptyPos.y);
  }

  void _slideAcres(Acre acre) {
    if (acre.type == AcreType.empty || !_acreSlideable(acre)) return;
    Position targetEmpty = acre.position;
    int dx = (acre.position.x - emptyPos.x).sign;
    int dy = (acre.position.y - emptyPos.y).sign;

    setState(() {
      while (emptyPos != targetEmpty) {
        Position swapPos = Position(x: emptyPos.x + dx, y: emptyPos.y + dy);
        _acres[_posToIndex(emptyPos)] =
            _posToAcre(swapPos).copyWith(newP: emptyPos);
        _acres[_posToIndex(swapPos)] =
            Acre(position: swapPos, type: AcreType.empty);
        emptyPos = swapPos;
      }
    });
  }

  bool contiguous(Acre acre) {
    Position p = acre.position;
    return ((p.x > 0 &&
            acre.openL &&
            _posToAcre(Position(x: p.x - 1, y: p.y)).openR &&
            _posToAcre(Position(x: p.x - 1, y: p.y)).saturation) ||
        (p.x < widget.size - 1 &&
            acre.openR &&
            _posToAcre(Position(x: p.x + 1, y: p.y)).openL &&
            _posToAcre(Position(x: p.x + 1, y: p.y)).saturation) ||
        (p.y > 0 &&
            acre.openT &&
            _posToAcre(Position(x: p.x, y: p.y - 1)).openB &&
            _posToAcre(Position(x: p.x, y: p.y - 1)).saturation) ||
        (p.y < widget.size - 1 &&
            acre.openB &&
            _posToAcre(Position(x: p.x, y: p.y + 1)).openT &&
            _posToAcre(Position(x: p.x, y: p.y + 1)).saturation));
  }

  void irrigate() {
    for (int i = 0; i < _acres.length; i++) {
      Acre acre = _acres[i];
      if ((acre.type == AcreType.source || contiguous(acre))) {
        _acres[i] = acre.copyWith(newS: true);
      } else {
        _acres[i] = acre.copyWith(newS: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    irrigate();
    return GridView.count(
      primary: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: widget.size,
      children: _acres.map(
        (acre) {
          return AcreTile(
            acre: acre,
            clickHandler: _slideAcres,
          );
        },
      ).toList(),
    );
  }
}

class AcreTile extends StatelessWidget {
  const AcreTile({
    Key? key,
    required this.acre,
    required this.clickHandler,
  }) : super(key: key);

  final Acre acre;
  final void Function(Acre) clickHandler;

  @override
  Widget build(BuildContext context) {
    if (acre.type == AcreType.empty) {
      return Container();
    }
    return TextButton(
      style: TextButton.styleFrom(
          backgroundColor:
              acre.saturation ? Colors.green[100] : Colors.green[50]),
      child: Text(acre.toString()),
      onPressed: () {
        clickHandler(acre);
      },
    );
  }
}
