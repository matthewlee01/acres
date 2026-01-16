import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:acres/model/land.dart';
import 'package:url_launcher/url_launcher.dart';
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
        theme: ThemeData(
            fontFamily: "Comfortaa",
            colorScheme: ColorScheme.fromSeed(seedColor: globals.darkGreen)),
        home: Scaffold(
          appBar: AppBar(
            titleSpacing: 100,
            title: const Text(
              'acres',
              style: TextStyle(color: globals.beige, fontSize: 25.0),
            ),
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          ),
          drawer: Drawer(
            child: ColoredBox(
                color: globals.lightGreen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ColoredBox(
                      color: globals.beige,
                      child: Row(
                        children: [
                          Builder(
                            builder: (BuildContext context) {
                              return SizedBox(
                                width: 56,
                                height: 56,
                                child: IconButton(
                                  color: globals.darkGreen,
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                          const Spacer(),
                          const Text('acres',
                              style: TextStyle(
                                fontSize: 20,
                                color: globals.darkGreen,
                              )),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("a game about irrigation!"),
                          SizedBox(height: 15),
                          Text(
                              "coded with flutter, animated with rive, and hosted with firebase."),
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: RichText(
                        text: TextSpan(children: [
                          const TextSpan(
                              text: 'built by ',
                              style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  color: Colors.black)),
                          TextSpan(
                              text: "matthew lee",
                              style: const TextStyle(
                                  fontFamily: 'Comfortaa',
                                  color: globals.darkGreen),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  const url = "https://twitter.com/matthew_j_l";
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                }),
                        ]),
                      ),
                    )
                  ],
                )),
          ),
          body: const ColoredBox(
            color: globals.bgGreen,
            child: Center(
              child: Land(),
            ),
          ),
        ));
  }
}
