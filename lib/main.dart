import 'package:flutter/material.dart';
import 'package:acres/model/land.dart';

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
