import 'dart:convert';
import 'dart:math';

import 'package:colyakapp/BarcodeJson.dart';
import 'package:colyakapp/BarcodeScanResult.dart';
import 'package:colyakapp/BolusReportScreen.dart';
import 'package:colyakapp/HttpBuild.dart';
import 'package:colyakapp/MealScreen.dart';
import 'package:colyakapp/QuizScreen.dart';
import 'package:colyakapp/Suggestion.dart';
import 'package:colyakapp/UserGuides.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String result = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A37).withOpacity(0.75),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Çölyak Diyabet'),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner),
              title: const Text('Haftalık Bolus Raporu'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BolusReportScreen()),
                ).then((value) {
                  if (value != null) {
                    setState(() {});
                  }
                });
              },
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Divider(),
            ),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Quizler'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizScreen()),
                ).then((value) {
                  if (value != null) {
                    setState(() {});
                  }
                });
              },
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Divider(),
            ),
            ListTile(
              leading: const Icon(Icons.tips_and_updates),
              title: const Text('Öneri Yap'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Suggestion()),
                ).then((value) {
                  if (value != null) {
                    setState(() {});
                  }
                });
              },
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Divider(),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Faydalı Bilgiler'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserGuides()),
                ).then((value) {
                  if (value != null) {
                    setState(() {});
                  }
                });
              },
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Divider(),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Çıkış Yap'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacementNamed("/loginscreen");
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(title: const Text("Çölyak Diyabet")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text("Hoş geldin,"),
                    Text(userName),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text("Özet"), Text("Detaylar")],
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Column(
                                  children: [Text("1500"), Text("Alınan")],
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        child: CustomPaint(
                                          painter: ArchProgressPainter(
                                              circularProgressSize:
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                              progress: 0.5),
                                          child: const Center(
                                              child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text("1000"),
                                              Text("Kalan"),
                                            ],
                                          )),
                                        )),
                                  ],
                                ),
                                const Column(
                                  children: [Text("2500"), Text("Hedef")],
                                )
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text("Karbonhidrat"),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 5, 0, 5),
                                          child: LinearProgressIndicator(
                                            value: 10,
                                            minHeight: 6,
                                          ),
                                        ),
                                        Text("15 / 150 g")
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text("Protein"),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 5, 0, 5),
                                          child: LinearProgressIndicator(
                                            value: 10,
                                            minHeight: 6,
                                          ),
                                        ),
                                        Text("32 / 125 g")
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text("Yağ"),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 5, 0, 5),
                                          child: LinearProgressIndicator(
                                            value: 10,
                                            minHeight: 6,
                                          ),
                                        ),
                                        Text("25 / 75 g")
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(10, 5, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Yapılabilecekler"),
                  ],
                ),
              ),
              Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MealScreen()),
                        ).then((value) {
                          if (value != null) {
                            setState(() {});
                          }
                        });
                      },
                      child: const Text("Öğün Ekle")),
                  ElevatedButton(
                      onPressed: () async {
                        await scanBarcodeNormal();
                        await barkodGonder();
                      },
                      child: const Text("Barkod Tara")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  String _scanBarcodeResult = "";

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      debugPrint(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = "Failed to get platform version.";
    }
    if (mounted) {
      setState(() {
        _scanBarcodeResult = barcodeScanRes;
      });
    }
  }

Future<void> barkodGonder() async {
    try {
      final response = await sendRequest(
          'GET', 'api/barcodes/code/$_scanBarcodeResult',
          token: globaltoken, context: context);
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        BarcodeJson veri = BarcodeJson.fromJson(data);
        bool confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Barkod Taraması'),
                  content: Text('Ürün: ${veri.name}'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Hayır'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Evet'),
                    ),
                  ],
                );
              },
            ) ??
            false;

        if (confirmed) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BarcodeScanResult(
                barcodeList: [veri],
              ),
            ),
          );
        }
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              children: [
                const Text('Tekrar taramayı deneyin!'),
                Text(response.statusCode.toString()),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }
}

class CircularProgressPainter extends CustomPainter {
  final double circularProgressSize;
  final double progress;
  final onePercentageToRadian = 0.06283;

  CircularProgressPainter({
    required this.circularProgressSize,
    required this.progress,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paintBackhround = Paint()
      ..strokeWidth = 16
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;

    final paintProgress = Paint()
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.green;

    canvas.drawCircle(
      Offset(circularProgressSize / 2, circularProgressSize / 2),
      circularProgressSize / 2,
      paintBackhround,
    );

    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(circularProgressSize / 2, circularProgressSize / 2),
          width: circularProgressSize,
          height: circularProgressSize),
      3 * pi / 2,
      _convertPercentageToRadian(),
      false,
      paintProgress,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  double _convertPercentageToRadian() {
    return onePercentageToRadian * progress * 100;
  }
}

class ArchProgressPainter extends CustomPainter {
  final double circularProgressSize;
  final double progress;
  final onePercentageToRadian = (3 * pi / 2) / 100;

  ArchProgressPainter({
    required this.circularProgressSize,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintBackhround = Paint()
      ..strokeWidth = 16
      ..color = const Color(0xFFFF7A37).withOpacity(0.25)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintProgress = Paint()
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFF7A37);

    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(circularProgressSize / 2, circularProgressSize / 2),
          width: circularProgressSize,
          height: circularProgressSize),
      3 * pi / 4,
      3 * pi / 2,
      false,
      paintBackhround,
    );

    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(circularProgressSize / 2, circularProgressSize / 2),
          width: circularProgressSize,
          height: circularProgressSize),
      3 * pi / 4,
      _convertPercentageToRadian(),
      false,
      paintProgress,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  double _convertPercentageToRadian() {
    return onePercentageToRadian * progress * 100;
  }
}
