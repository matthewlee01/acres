import 'package:flutter/material.dart';
import 'package:acres/model/land.dart';
import 'globals.dart' as globals;

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'acres',
        home: Column(
          children: const <Widget>[
            ColoredBox(
              color: globals.darkGreen,
              child: SizedBox(
                width: double.infinity,
                height: globals.menuHeight,
                child: Text("hi"),
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: globals.bgGreen,
                child: Center(
                  child: Land(),
                ),
              ),
            ),
          ],
        ));
  }
}
