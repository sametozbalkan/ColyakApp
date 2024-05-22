import 'dart:convert';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color:  Colors.white38,
              ),
              child:  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Image.asset("assets/images/colyak.png")),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner),
              title: const Text('Bolus Raporları'),
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
              leading: const Icon(Icons.settings),
              title: const Text('Ayarlar'),
              onTap: () {},
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
                padding: const EdgeInsets.all(5),
                child: Text(
                  "Hoş geldin, $userName!",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                      children: [
                        GestureDetector(
                          onTap: () {
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
                          child: const Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Öğün Ekle"),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await scanBarcodeNormal();
                            await barkodGonder();
                          },
                          child: const Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Barkod Tara"),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {},
                          child: const Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Çek"),
                              ],
                            ),
                          ),
                        ),
                        const Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Çek"),
                            ],
                          ),
                        ),
                        const Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Çek"),
                            ],
                          ),
                        ),
                        const Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Çek"),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
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
                barcode: veri,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tekrar taramayı deneyin!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ürün bulunamadı:  ${response.statusCode}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }
}
