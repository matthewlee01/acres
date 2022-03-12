import 'package:flutter/material.dart';
import 'package:acres/model/land.dart';

const double landWidth = 350;
const double landHeight = 350;
const Color mainGreen = Color(0xFF80BE4C);
void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  static const size = 4;
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'acres',
      home: ColoredBox(
        color: mainGreen,
        child: Center(
          child: Land(),
        ),
      ),
    );
  }
}
