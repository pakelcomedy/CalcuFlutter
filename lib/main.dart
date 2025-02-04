import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Hanya mengizinkan orientasi portrait.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const CalculatorApp());
  });
}

/// Aplikasi utama yang mendukung toggle tema secara dinamis.
class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool _isDarkTheme = true;

  /// Fungsi untuk toggle antara tema gelap dan terang.
  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 48, color: Colors.black87, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 34, color: Colors.deepPurple),
        bodyLarge: TextStyle(fontSize: 24, color: Colors.black87),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.black,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 34, color: Colors.amberAccent),
        bodyLarge: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Scientific Calculator',
      debugShowCheckedModeBanner: false,
      theme: _isDarkTheme ? _buildDarkTheme() : _buildLightTheme(),
      home: CalculatorScreen(
        onToggleTheme: _toggleTheme,
        isDarkTheme: _isDarkTheme,
      ),
    );
  }
}

/// Layar kalkulator utama.
class CalculatorScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;
  const CalculatorScreen(
      {super.key, required this.onToggleTheme, required this.isDarkTheme});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  String _expression = "";
  String _result = "";
  final List<String> _history = [];
  bool _showScientific = false; // Toggle untuk menampilkan tombol ilmiah
  double _memory = 0.0; // Nilai memori

  /// Daftar operator yang akan diperlakukan khusus jika muncul secara berurutan.
  final List<String> _operatorSymbols = ["+", "-", "÷", "x", "^", "%"];

  /// Menambahkan input ke ekspresi.
  /// Jika input yang diberikan adalah operator dan karakter terakhir dari _expression
  /// sudah merupakan operator (misalnya +, -, dll), maka operator tersebut akan digantikan.
  void _numClick(String text) {
    setState(() {
      // Jika input adalah salah satu fungsi ilmiah, tambahkan dengan tanda kurung buka.
      if (["sin", "cos", "tan", "ln", "log", "√"].contains(text)) {
        if (text == "√") {
          _expression += "sqrt(";
        } else {
          _expression += "$text(";
        }
      }
      // Jika input adalah operator matematika (misalnya +, -, ÷, x, ^, %).
      else if (_operatorSymbols.contains(text)) {
        // Jika ekspresi masih kosong, hanya perbolehkan '-' untuk angka negatif.
        if (_expression.isEmpty) {
          if (text == "-") {
            _expression += text;
          }
          // Jika operator lain di awal, abaikan.
          return;
        } else {
          // Dapatkan karakter terakhir dari _expression.
          String lastChar = _expression[_expression.length - 1];

          // Jika karakter terakhir sudah merupakan operator, gantikan dengan operator baru.
          if (_operatorSymbols.contains(lastChar)) {
            _expression =
                _expression.substring(0, _expression.length - 1) + text;
          } else {
            _expression += text;
          }
        }
      }
      // Untuk input selain fungsi ilmiah dan operator (misalnya angka, titik, atau tanda kurung lainnya)
      else {
        _expression += text;
      }
    });
  }

  /// Menghapus seluruh ekspresi dan hasil serta menyimpan ke history.
  void _allClear() {
    setState(() {
      if (_expression.isNotEmpty || _result.isNotEmpty) {
        _history.add("$_expression = $_result");
      }
      _expression = "";
      _result = "";
    });
  }

  /// Menghapus karakter terakhir dari ekspresi.
  void _clear() {
    setState(() {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    });
  }

  /// Mengevaluasi ekspresi matematika.
  void _evaluate() {
    try {
      Parser parser = Parser();
      // Ganti tanda "x" dan "÷" dengan operator perkalian dan pembagian yang sesuai.
      String finalExpression =
          _expression.replaceAll('x', '*').replaceAll('÷', '/');
      Expression exp = parser.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      setState(() {
        _result = eval.toString();
        _history.add("$_expression = $_result");
      });
    } catch (e) {
      setState(() {
        _result = "Error";
      });
    }
  }

  /// Fungsi memori: menyimpan nilai ke memori berdasarkan ekspresi saat ini.
  void _memoryStore() {
    try {
      Parser parser = Parser();
      String finalExpression =
          _expression.replaceAll('x', '*').replaceAll('÷', '/');
      Expression exp = parser.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      setState(() {
        _memory = eval;
      });
    } catch (e) {
      setState(() {
        _result = "Error";
      });
    }
  }

  /// Fungsi memori: memanggil nilai yang disimpan di memori ke ekspresi.
  void _memoryRecall() {
    setState(() {
      // Jika ekspresi tidak kosong dan karakter terakhir bukan operator, maka tambahkan operator "*"
      // untuk menggabungkan nilai memori ke ekspresi secara eksplisit.
      if (_expression.isNotEmpty &&
          !_operatorSymbols.contains(_expression[_expression.length - 1])) {
        _expression += "*";
      }
      _expression += _memory.toString();
    });
  }

  /// Fungsi memori: menambahkan nilai hasil evaluasi ekspresi saat ini ke nilai memori.
  void _memoryAdd() {
    try {
      Parser parser = Parser();
      String finalExpression =
          _expression.replaceAll('x', '*').replaceAll('÷', '/');
      Expression exp = parser.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      setState(() {
        _memory += eval;
      });
    } catch (e) {
      setState(() {
        _result = "Error";
      });
    }
  }

  /// Fungsi memori: mengurangkan nilai hasil evaluasi ekspresi saat ini dari nilai memori.
  void _memorySubtract() {
    try {
      Parser parser = Parser();
      String finalExpression =
          _expression.replaceAll('x', '*').replaceAll('÷', '/');
      Expression exp = parser.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      setState(() {
        _memory -= eval;
      });
    } catch (e) {
      setState(() {
        _result = "Error";
      });
    }
  }

  /// Daftar tombol fungsi ilmiah.
  final List<Map<String, dynamic>> _scientificButtons = [
    {"text": "sin", "color": Colors.deepPurpleAccent},
    {"text": "cos", "color": Colors.deepPurpleAccent},
    {"text": "tan", "color": Colors.deepPurpleAccent},
    {"text": "ln", "color": Colors.deepPurpleAccent},
    {"text": "log", "color": Colors.deepPurpleAccent},
    {"text": "√", "color": Colors.deepPurpleAccent},
    {"text": "(", "color": Colors.grey},
    {"text": ")", "color": Colors.grey},
    {"text": "^", "color": Colors.deepPurpleAccent},
    {"text": "%", "color": Colors.deepPurpleAccent},
  ];

  /// Daftar tombol kalkulator dasar.
  final List<Map<String, dynamic>> _basicButtons = [
    {"text": "AC", "color": Colors.redAccent},
    {"text": "C", "color": Colors.blueAccent},
    {"text": "÷", "color": Colors.blueAccent},
    {"text": "x", "color": Colors.blueAccent},
    {"text": "7", "color": Colors.grey},
    {"text": "8", "color": Colors.grey},
    {"text": "9", "color": Colors.grey},
    {"text": "-", "color": Colors.blueAccent},
    {"text": "4", "color": Colors.grey},
    {"text": "5", "color": Colors.grey},
    {"text": "6", "color": Colors.grey},
    {"text": "+", "color": Colors.blueAccent},
    {"text": "1", "color": Colors.grey},
    {"text": "2", "color": Colors.grey},
    {"text": "3", "color": Colors.grey},
    {"text": "=", "color": Colors.green},
    {"text": "0", "color": Colors.grey},
    {"text": ".", "color": Colors.grey},
  ];

  /// Daftar tombol memori.
  final List<Map<String, dynamic>> _memoryButtons = [
    {"text": "MC", "color": Colors.orange},
    {"text": "MR", "color": Colors.orange},
    {"text": "M+", "color": Colors.orange},
    {"text": "M-", "color": Colors.orange},
  ];

  /// Widget tombol kalkulator berbentuk bundar.
  Widget buildButton(String text, Color color) {
    return ElevatedButton(
      onPressed: () {
        // Penanganan tombol memori.
        if (_memoryButtons.any((btn) => btn['text'] == text)) {
          if (text == "MC") {
            setState(() {
              _memory = 0.0;
            });
          } else if (text == "MR") {
            _memoryRecall();
          } else if (text == "M+") {
            _memoryAdd();
          } else if (text == "M-") {
            _memorySubtract();
          }
        }
        // Penanganan tombol kalkulator dasar dan ilmiah.
        else if (text == "AC") {
          _allClear();
        } else if (text == "C") {
          _clear();
        } else if (text == "=") {
          _evaluate();
        } else {
          _numClick(text);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        elevation: 5,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }

  /// Widget untuk menampilkan history perhitungan.
  Widget _buildHistorySheet() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: _history.isEmpty
          ? const Center(
              child: Text(
                "Belum ada perhitungan",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _history[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil nilai safe area (padding bawah) dari MediaQuery.
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Scientific Calculator"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "History",
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => _buildHistorySheet(),
                backgroundColor: Colors.black87,
              );
            },
          ),
          IconButton(
            icon: Icon(widget.isDarkTheme ? Icons.wb_sunny : Icons.nights_stay),
            tooltip: "Toggle Theme",
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isDarkTheme
                  ? const [Color(0xFF232526), Color(0xFF414345)]
                  : const [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Tampilan ekspresi dan hasil.
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          _expression,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _result,
                        key: const Key('result'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
              // Tombol toggle untuk mode ilmiah.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showScientific = !_showScientific;
                    });
                  },
                  icon: Icon(
                    _showScientific ? Icons.keyboard_hide : Icons.science,
                    color: Colors.white,
                  ),
                  label: Text(
                    _showScientific ? "Sembunyikan Ilmiah" : "Tampilkan Ilmiah",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              // Baris tombol memori.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _memoryButtons.map((button) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: buildButton(
                            button['text'], button['color'] as Color),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Jika mode ilmiah diaktifkan, tampilkan grid tombol ilmiah.
              if (_showScientific)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: _scientificButtons.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final button = _scientificButtons[index];
                      return buildButton(
                          button['text'], button['color'] as Color);
                    },
                  ),
                ),
              // Tombol kalkulator dasar.
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, bottomPadding + 8),
                  child: GridView.builder(
                    itemCount: _basicButtons.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final button = _basicButtons[index];
                      return buildButton(
                          button['text'], button['color'] as Color);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
