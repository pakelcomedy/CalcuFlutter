import 'dart:async';
import 'package:calculator/func.dart';
import 'package:calculator/settings.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String input = '';
  String output = '';
  String operation = '';
  String upper = '';
  bool answer = false;
  Timer? timer;
  String themel = '';
  bool crop = false;

  @override
  void initState() {
    super.initState();
    load().then((_) {
      setState(() {
        setTheme(context, theme);
      });
    });

    timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      if (themel != theme) {
        setState(() {
          themel = theme;
        });
      }
    });
  }

  /// Dummy evaluation function.
  /// Replace this with your actual calculation logic.
  dynamic evaluate(String input) {
    try {
      // Remove any commas and parse the input as a double.
      double result = double.parse(input.replaceAll(',', ''));
      return [result];
    } catch (e) {
      return "Error";
    }
  }

  void addDigit(String digit) {
    if (!answer) {
      setState(() {
        answer = true;
      });
    }
    if (input.replaceAll(',', '').length <= 52) {
      // Check for invalid inputs (e.g., starting with a symbol)
      if ((input.isEmpty && symbols.contains(digit)) ||
          (symbols.contains(digit) && input.characters.last == digit) ||
          (input == '0' && digit == '0')) {
        setState(() {});
      } else {
        if (input == '0' && !symbols.contains(digit)) {
          setState(() {
            input = digit;
          });
        } else {
          setState(() {
            input = addComma(input + digit)
                .replaceAll('*', 'x')
                .replaceAll('/', '÷')
                .replaceAll(' ', '');
          });
        }
      }
      if (!symbols.contains(digit)) {
        preOperate();
      }
    }
  }

  bool isNumeric(dynamic s) {
    s = s.toString();
    return double.tryParse(s) != null;
  }

  void preOperate() {
    var result = evaluate(input);
    if (result is String && result == "Error") {
      setState(() {
        upper = "Error";
      });
      return;
    }

    double eval = result[0];
    setState(() {
      if (isNumeric(eval)) {
        output = addComma(
          isInteger(eval) ? eval.toString() : eval.toStringAsFixed(0),
        );
        upper = output;
      } else {
        upper = result.toString();
      }
    });
  }

  void operate() {
    setState(() {
      answer = !answer;
    });
    var result = evaluate(input);
    if (result is String && result == "Error") {
      setState(() {
        output = "Error";
        input = "Error";
        upper = "Error";
      });
    } else {
      double eval = result[0];
      setState(() {
        output = addComma(
          isInteger(eval) ? eval.toString() : eval.toStringAsFixed(0),
        );
        upper = input;
        input = output;
      });
    }
  }

  void clear() {
    setState(() {
      input = '';
      upper = '';
      output = '';
      operation = '';
    });
  }

  void backSpace() {
    if (!answer) {
      setState(() {
        answer = true;
      });
    }
    if (input.isNotEmpty && input.characters.length >= 2) {
      setState(() {
        input = addComma(input.substring(0, input.length - 1))
            .replaceAll('*', 'x')
            .replaceAll('/', '÷');
      });
    } else {
      clear();
    }
    if (input.isNotEmpty && !symbols.contains(input.characters.last)) {
      preOperate();
    }
  }

  @override
  Widget build(BuildContext context) {
    double buttonHeight = MediaQuery.of(context).size.width / 7;
    Color primary = AdaptiveTheme.of(context).theme.primaryColor;
    Color secondary = AdaptiveTheme.of(context).theme.secondaryHeaderColor;
    Color back = AdaptiveTheme.of(context).theme.scaffoldBackgroundColor;
    Color? shadowDark = AdaptiveTheme.of(context).brightness == Brightness.dark
        ? Colors.black87
        : Colors.grey[400];
    Color? shadowLight = AdaptiveTheme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final Color textColor =
        AdaptiveTheme.of(context).theme.textTheme.labelLarge?.color ??
            Colors.black;

    return Scaffold(
      body: Background(
        child: SizedOverflowBox(
          size: Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FadeUp(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SettingScreen(),
                                ),
                              );
                            },
                            icon: Icon(Icons.settings, color: textColor)),
                        Text(
                          'Calculator',
                          style: TextStyle(fontSize: 22, color: textColor),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              AdaptiveTheme.of(context).brightness ==
                                      Brightness.dark
                                  ? AdaptiveTheme.of(context).setLight()
                                  : AdaptiveTheme.of(context).setDark();
                            });
                          },
                          icon: Icon(
                            AdaptiveTheme.of(context).brightness ==
                                    Brightness.dark
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: constraints.maxHeight / 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: AutoSizeText(
                                  upper,
                                  style: TextStyle(
                                    fontSize: 30,
                                    letterSpacing: 2,
                                    color: Color.fromRGBO(
                                      textColor.r.toInt(),
                                      textColor.g.toInt(),
                                      textColor.b.toInt(),
                                      0.5,
                                    ),
                                  ),
                                  minFontSize: 18,
                                  maxLines: 3,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: constraints.maxHeight / 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: AnimatedSwitcher(
                                  duration:
                                      const Duration(milliseconds: 0),
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    final offsetAnimation = Tween<Offset>(
                                            begin: const Offset(0.0, 1.0),
                                            end: const Offset(0.0, 0.0))
                                        .animate(animation);
                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                  child: answer
                                      ? AutoSizeText(
                                          input,
                                          key: const ValueKey(1),
                                          style: TextStyle(
                                            fontSize: 45,
                                            letterSpacing: 2,
                                            color: textColor,
                                          ),
                                          maxLines: 3,
                                          textAlign: TextAlign.left,
                                        )
                                      : AutoSizeText(
                                          output,
                                          key: const ValueKey(2),
                                          style: TextStyle(
                                            fontSize: 45,
                                            letterSpacing: 2,
                                            color: textColor,
                                          ),
                                          maxLines: 3,
                                          textAlign: TextAlign.left,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                          children: [
                            Button(
                              backColor: secondary,
                              onPress: () {
                                clear();
                              },
                              text: const Text(
                                'C',
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Button(
                              backColor: secondary,
                              onPress: () {
                                backSpace();
                              },
                              text: const Icon(
                                MaterialCommunityIcons.backspace,
                                size: 28,
                                color: Colors.black,
                              ),
                            ),
                            Button(
                              backColor: primary,
                              onPress: () {
                                addDigit('%');
                              },
                              text: const Text(
                                '%',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Button(
                              backColor: primary,
                              onPress: () {
                                addDigit('÷');
                              },
                              text: const Icon(
                                MaterialCommunityIcons.division,
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        for (var i in keys)
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              for (var j in i)
                                Button(
                                  backColor: back,
                                  onPress: () {
                                    addDigit(j);
                                  },
                                  text: Text(
                                    j,
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: textColor),
                                  ),
                                ),
                              Button(
                                backColor: primary,
                                onPress: () {
                                  addDigit(i.last == '9'
                                      ? 'x'
                                      : i.last == '6'
                                          ? "-"
                                          : "+");
                                },
                                text: i.last == '9'
                                    ? const Icon(Icons.close,
                                        color: Colors.white)
                                    : i.last == '6'
                                        ? const Icon(Icons.remove,
                                            color: Colors.white)
                                        : const Icon(Icons.add,
                                            color: Colors.white),
                              ),
                            ],
                          ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                          children: [
                            FadeUp(
                              child: NeumorphicButton(
                                margin: const EdgeInsets.only(
                                    bottom: 15),
                                onPressed: () {
                                  addDigit('0');
                                },
                                style: NeumorphicStyle(
                                  shadowLightColor: shadowLight,
                                  shadowDarkColor: shadowDark,
                                  shape: NeumorphicShape.concave,
                                  boxShape: NeumorphicBoxShape
                                      .roundRect(
                                          BorderRadius.circular(18)),
                                  color: back,
                                  depth: 10,
                                  intensity: 0.7,
                                  surfaceIntensity: 0.35,
                                  lightSource: LightSource.topLeft,
                                ),
                                child: SizedBox(
                                  width: MediaQuery.of(context)
                                          .size
                                          .width /
                                      3,
                                  height: buttonHeight,
                                  child: Center(
                                    child: Text(
                                      "0",
                                      style: TextStyle(
                                          fontSize: 25,
                                          color: textColor),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Button(
                              backColor: back,
                              onPress: () {
                                addDigit('.');
                              },
                              text: Text(
                                ".",
                                style: TextStyle(
                                  fontSize: 25,
                                  color: textColor,
                                ),
                              ),
                            ),
                            Button(
                              backColor: primary,
                              onPress: () {
                                operate();
                              },
                              text: const Text(
                                '=',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}