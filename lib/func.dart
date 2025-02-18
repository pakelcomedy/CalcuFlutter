import 'dart:math';
import 'package:flutter/services.dart';
import 'package:calculator/settings.dart'; // Make sure this file defines globals like dark, vibrate, sound, and theme.
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Consts
const List<String> ops = ['*', '-', '+', '%', '/'];
const List<String> symbols = ['x', '-', '+', '%', '.', '÷'];
Parser p = Parser();
ContextModel cm = ContextModel();
const List<List<String>> keys = [
  ["7", "8", "9"],
  ["4", "5", "6"],
  ["1", "2", "3"]
];

// Functions

Future<void> save() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('dark', dark);
  await prefs.setBool('vibrate', vibrate);
  await prefs.setBool('sound', sound);
  await prefs.setString('theme', theme);
}

Future<void> load() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  dark = prefs.getBool('dark') ?? true;
  vibrate = prefs.getBool('vibrate') ?? true;
  sound = prefs.getBool('sound') ?? false;
  theme = prefs.getString('theme') ?? 'default';
}

String addComma(String inp) {
  var x = inp.replaceAll(',', '');
  x = x.replaceAll('x', '*');
  x = x.replaceAll('÷', '/');
  // Insert spaces around operators
  for (var op in ops) {
    x = x.replaceAll(op, " $op ");
  }
  List<String> parts = x.split(' ');
  List<String> formattedParts = [];
  for (var part in parts) {
    if (!ops.contains(part)) {
      String d = '';
      if (part.contains('.')) {
        var splitNum = part.split('.');
        var integerPart = splitNum[0].replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
        d = '$integerPart.${splitNum[1]}';
      } else {
        d = part.replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
      }
      formattedParts.add(d);
    } else {
      formattedParts.add(part);
    }
  }
  String formatted = formattedParts.join();
  return formatted;
}

bool isInteger(num value) {
  // Returns true if the value has no fractional part.
  return value is int || value == value.toInt();
}

dynamic evaluateExpression(String inp) {
  try {
    var x = inp.replaceAll(',', '');
    x = x.replaceAll('x', '*');
    x = x.replaceAll('÷', '/');
    Expression exp = p.parse(x);
    double eval = exp.evaluate(EvaluationType.REAL, cm);
    return [eval, exp];
  } catch (e) {
    return "Error";
  }
}

Future<void> vibrator() async {
  HapticFeedback.mediumImpact();
}

void setTheme(context, mode) {
  if (mode == 'default') {
    AdaptiveTheme.of(context).setTheme(
      light: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.orange,
        secondaryHeaderColor: Colors.grey[400],
        scaffoldBackgroundColor: Colors.white, // Perbaikan
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.orange,
        secondaryHeaderColor: Colors.grey,
        scaffoldBackgroundColor: Colors.grey[900], // Perbaikan
      ),
    );
  } else if (mode == 'red') {
    AdaptiveTheme.of(context).setTheme(
      light: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.red,
        secondaryHeaderColor: Colors.grey[400],
        scaffoldBackgroundColor: Colors.white, // Perbaikan
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red,
        secondaryHeaderColor: Colors.grey,
        scaffoldBackgroundColor: Colors.grey[900], // Perbaikan
      ),
    );
  } else if (mode == 'green') {
    AdaptiveTheme.of(context).setTheme(
      light: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.green,
        secondaryHeaderColor: Colors.grey[400],
        scaffoldBackgroundColor: Colors.white, // Perbaikan
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green,
        secondaryHeaderColor: Colors.grey,
        scaffoldBackgroundColor: Colors.grey[900], // Perbaikan
      ),
    );
  } else if (mode == 'blue') {
    AdaptiveTheme.of(context).setTheme(
      light: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        secondaryHeaderColor: Colors.grey[400],
        scaffoldBackgroundColor: Colors.white, // Perbaikan
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        secondaryHeaderColor: Colors.grey,
        scaffoldBackgroundColor: Colors.grey[900], // Perbaikan
      ),
    );
  } else if (mode == 'purple') {
    AdaptiveTheme.of(context).setTheme(
      light: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.purple,
        secondaryHeaderColor: Colors.grey[400],
        scaffoldBackgroundColor: Colors.white, // Perbaikan
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.purple,
        secondaryHeaderColor: Colors.grey,
        scaffoldBackgroundColor: Colors.grey[900], // Perbaikan
      ),
    );
  }
}

// Widgets

class Background extends StatefulWidget {
  const Background({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  @override
  Widget build(BuildContext context) {
    if (AdaptiveTheme.of(context).brightness == Brightness.dark) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: widget.child,
      );
    } else {
      return NeumorphicBackground(
        child: widget.child,
      );
    }
  }
}

class Button extends StatefulWidget {
  const Button({
    Key? key,
    required this.backColor,
    required this.text,
    required this.onPress,
  }) : super(key: key);

  final Color backColor;
  final Widget text;
  final VoidCallback onPress;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width / 10;
    double buttonHeight = MediaQuery.of(context).size.width / 7;

    Color? shadowDark = AdaptiveTheme.of(context).brightness == Brightness.dark
        ? Colors.black87
        : Colors.grey[400];
    Color? shadowLight = AdaptiveTheme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;

    return FadeUp(
      child: NeumorphicButton(
        margin: const EdgeInsets.only(bottom: 15),
        onPressed: () async {
          widget.onPress();
          if (vibrate) {
            await vibrator();
          }
          if (sound) {
            SystemSound.play(SystemSoundType.click);
          }
        },
        style: NeumorphicStyle(
          shadowLightColor: shadowLight,
          shadowDarkColor: shadowDark,
          shape: NeumorphicShape.concave,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
          color: widget.backColor,
          depth: 10,
          intensity: 0.7,
          surfaceIntensity: 0.35,
          lightSource: LightSource.topLeft,
        ),
        child: SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: Center(
            child: widget.text,
          ),
        ),
      ),
    );
  }
}

class FadeUp extends StatefulWidget {
  const FadeUp({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  State<FadeUp> createState() => _FadeUpState();
}

class _FadeUpState extends State<FadeUp> {
  final Random rnd = Random();

  @override
  Widget build(BuildContext context) {
    return ShowUpAnimation(
      delayStart: const Duration(seconds: 0),
      animationDuration: Duration(milliseconds: 300 + rnd.nextInt(500)),
      curve: Curves.bounceIn,
      direction: Direction.vertical,
      offset: 0.2,
      child: widget.child,
    );
  }
}