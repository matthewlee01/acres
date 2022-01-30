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
                child: AspectRatio(aspectRatio: 1, child: Land(size: size)))));
  }
}

class Land extends StatelessWidget {
  const Land({
    Key? key,
    required this.size,
  }) : super(key: key);

  final int size;

  List<Acre> generateAcres(int size) {
    List<Acre> acres = [];
    for (int i = 0; i < (size * size) - 1; i++) {
      acres.add(Acre(
          position: Position(x: i ~/ size, y: i % size), type: AcreType.open));
    }
    return acres;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        primary: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: size,
        children: generateAcres(size).map((acre) {
          return AcreTile(
            acre: acre,
          );
        }).toList());
  }
}

class AcreTile extends StatelessWidget {
  const AcreTile({Key? key, required this.acre}) : super(key: key);

  final Acre acre;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(acre.toString()),
      onPressed: () {},
    );
  }
}
