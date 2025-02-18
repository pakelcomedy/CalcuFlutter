import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:calculator/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.orange,
        secondaryHeaderColor: Colors.grey[400]!,
        colorScheme: ColorScheme.light().copyWith(
          primary: Colors.orange,
          secondary: Colors.blue,
          surface: Colors.white,
        ),
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.orange,
        secondaryHeaderColor: Colors.grey,
        colorScheme: ColorScheme.dark().copyWith(
          primary: Colors.orange,
          secondary: Colors.blue,
          surface: Colors.grey[900]!,
        ),
      ),
      initial: AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Calculator',
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
        theme: ThemeData(
          textTheme: GoogleFonts.rubikTextTheme(Theme.of(context).textTheme),
        ),
      ),
    );
  }
}