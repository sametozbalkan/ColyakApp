import 'dart:convert';
import 'package:colyakapp/BarcodeJson.dart';
import 'package:colyakapp/BarcodeScanResult.dart';
import 'package:colyakapp/BolusReportScreen.dart';
import 'package:colyakapp/HttpBuild.dart';
import 'package:colyakapp/MealScreen.dart';
import 'package:colyakapp/QuizScreen.dart';
import 'package:colyakapp/ReceiptDetailScreen.dart';
import 'package:colyakapp/ReceiptJson.dart';
import 'package:colyakapp/Suggestion.dart';
import 'package:colyakapp/UserGuides.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = false;
  List<ReceiptJson> receipts = [];
  Map<String, Uint8List?> imageBytesMap = {};
  bool _imagesLoaded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _showLeftArrow = _scrollController.offset > 0;
      _showRightArrow =
          _scrollController.offset < _scrollController.position.maxScrollExtent;
    });
  }

  Future<void> initializeData() async {
    try {
      await _top5receipts();
      await _loadImageBytes();
    } catch (e) {
      print("Critical error posting refresh token: $e");
    }
  }

  Future<void> _top5receipts() async {
    var response = await sendRequest("GET", "api/meals/report/top5receipts",
        token: globaltoken, context: context);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    if (mounted) {
      setState(() {
        receipts = data.map((json) => ReceiptJson.fromJson(json)).toList();
      });
    }
  }

  Future<String> scanBarcodeNormal(BuildContext context) async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      debugPrint(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = "Failed to get platform version.";
    }
    if (barcodeScanRes == "-1") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Barkod bulunamadı!"),
          duration: Duration(seconds: 2),
        ),
      );
    }
    return barcodeScanRes;
  }

  Future<void> barkodGonder(BuildContext context, String barcode) async {
    try {
      final response = await sendRequest('GET', 'api/barcodes/code/$barcode',
          token: globaltoken, context: context);
      if (response.statusCode == 200) {
        BarcodeJson veri =
            BarcodeJson.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        bool confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Barkod Taraması'),
                  content: Text('Ürün: ${veri.name}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Hayır'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
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
                builder: (context) => BarcodeScanResult(barcode: veri)),
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
            content: Text('Ürün bulunamadı: ${response.statusCode}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadImageBytes() async {
    for (ReceiptJson receipt in receipts) {
      String imageUrl =
          "https://api.colyakdiyabet.com.tr/api/image/get/${receipt.imageId}";
      if (!imageBytesMap.containsKey(imageUrl)) {
        var response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200 && mounted) {
          setState(() {
            imageBytesMap[imageUrl] = response.bodyBytes;
          });
        } else {
          print('Resim alınamadı. Hata kodu: ${response.statusCode}');
        }
      }
    }
    if (mounted) {
      setState(() {
        _imagesLoaded = true;
      });
    }
  }

  Widget _buildReceiptCard(ReceiptJson receipt) {
    String imageUrl =
        "https://api.colyakdiyabet.com.tr/api/image/get/${receipt.imageId}";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptDetailScreen(
              receipt: receipt,
              imageBytes: imageBytesMap[imageUrl]!,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageBytesMap.containsKey(imageUrl))
              Expanded(
                flex: 7,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Image.memory(
                    imageBytesMap[imageUrl]!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      receipt.receiptName!,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.white38,
              ),
              child: Column(
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
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Quizler'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.tips_and_updates),
              title: const Text('Öneri Yap'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Suggestion()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Faydalı Bilgiler'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserGuides()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ayarlar'),
              onTap: () {},
            ),
            const Divider(),
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
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Hoş geldin, $userName!",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10, bottom: 5, top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Neler yapılabilir?", style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                ),
                children: [
                  GestureDetector(
                    onTap: () async {
                      String barcode = await scanBarcodeNormal(context);
                      if (barcode != "-1") {
                        await barkodGonder(context, barcode);
                      }
                    },
                    child: const Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.barcode_reader, size: 32),
                          ListTile(
                            title: Text("Barkod Tarayıcı"),
                            subtitle:
                                Text("Hazır gıdalar için barkod tarayıcı"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Çek"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "En Çok Tercih Edilen 5 Tarif",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 4,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: _imagesLoaded
                              ? GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                  ),
                                  controller: _scrollController,
                                  itemCount: receipts.length,
                                  itemBuilder: (context, index) {
                                    return _buildReceiptCard(receipts[index]);
                                  },
                                )
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _showLeftArrow
                                ? () {
                                    _scrollController.animateTo(
                                      _scrollController.offset -
                                          MediaQuery.of(context).size.width,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.ease,
                                    );
                                  }
                                : null,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: _showRightArrow
                                ? () {
                                    _scrollController.animateTo(
                                      _scrollController.offset +
                                          MediaQuery.of(context).size.width,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.ease,
                                    );
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Öğün Ekle",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MealScreen()),
                      );
                    },
                    child: const Card(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: ListTile(
                          title: Text("Öğün Listem"),
                          subtitle: Text(
                              "Bolus hesaplamak için yediklerini seçip öğün listeni oluştur."),
                          leading: Icon(Icons.restaurant),
                          trailing: Icon(Icons.arrow_forward_sharp),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
