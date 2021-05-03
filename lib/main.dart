import 'package:flutter/material.dart';

import './MainPage.dart';

const MaterialColor kPrimaryColor = const MaterialColor(
  0xFF0E7AC7,
  const <int, Color>{
    50: const Color(0xFF0382F7),
    100: const Color(0xFF0382F7),
    200: const Color(0xFF0382F7),
    300: const Color(0xFF0382F7),
    400: const Color(0xFF0382F7),
    500: const Color(0xFF0382F7),
    600: const Color(0xFF0382F7),
    700: const Color(0xFF0382F7),
    800: const Color(0xFF0382F7),
    900: const Color(0xFF0382F7),
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: kPrimaryColor[100],
        accentColor: Colors.white,
        textTheme: ThemeData.light().textTheme.copyWith(
              bodyText1: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              bodyText2: TextStyle(
                color: Colors.white,
              ),
              headline6: TextStyle(
                color: Colors.redAccent,
                fontSize: 20,
              ),
              headline5: TextStyle(
                color: kPrimaryColor[100],
                fontSize: 12,
              ),
              headline4: TextStyle(
                color: kPrimaryColor[100],
                fontSize: 14,
              ),
              headline3: TextStyle(
                color: kPrimaryColor[100],
                fontSize: 16,
              ),
              headline2: TextStyle(
                color: kPrimaryColor[100],
                fontSize: 18,
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
