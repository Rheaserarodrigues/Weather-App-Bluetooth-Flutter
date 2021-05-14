import 'package:flutter/material.dart';
import './MainPage.dart';
const MaterialColor kPrimaryColor = const MaterialColor(
  0xFF0E7AC7,
  const <int, Color>{
    50: const Color(0xFF0382F7),
    100: const Color(0xFF0382F7),
  },
);

void main() => runApp(new ExampleApplication());

class ExampleApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
      debugShowCheckedModeBanner: false,
      title: '',
      theme: ThemeData(

        primaryColor: kPrimaryColor[100],
        accentColor: Colors.white,
        textTheme: ThemeData.light().textTheme.copyWith(

              headline3: TextStyle(
                color: kPrimaryColor[100],
                fontSize: 16,
              ),
              headline2: TextStyle(
                color: kPrimaryColor[100],
                fontSize: 22,
              ),
              headline1: TextStyle(
                color: kPrimaryColor[100],
                fontSize: 25,
              ),
            ),
      ),
    );
  }
}
