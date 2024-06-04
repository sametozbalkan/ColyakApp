import 'dart:convert';
import 'package:colyakapp/BarcodeJson.dart';
import 'package:colyakapp/BarcodeScanResult.dart';
import 'package:colyakapp/BolusReportScreen.dart';
import 'package:colyakapp/HttpBuild.dart';
import 'package:colyakapp/MealScreen.dart';
import 'package:colyakapp/QuizScreen.dart';
import 'package:colyakapp/ReceiptDetailScreen.dart';
import 'package:colyakapp/ReceiptJson.dart';
import 'package:colyakapp/SettingsScreen.dart';
import 'package:colyakapp/Shimmer.dart';
import 'package:colyakapp/Suggestion.dart';
import 'package:colyakapp/UserGuides.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  List<ReceiptJson> receipts = [];
  Map<String, Uint8List?> imageBytesMap = {};
  String barcodeScanRes = "";

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> initializeData() async {
    try {
      await _top5receipts();
      await _loadImageBytes();
    } catch (e) {
      print("Error initializing data: $e");
    }
  }

  Future<void> _top5receipts() async {
    var response = await HttpBuildService.sendRequest(
        "GET", "api/meals/report/top5receipts",
        token: true);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    if (mounted) {
      setState(() {
        receipts = data.map((json) => ReceiptJson.fromJson(json)).toList();
      });
    }
  }

  Future<String> scanBarcodeNormal(BuildContext context) async {
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      debugPrint(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = "Failed to get platform version.";
    }
    return barcodeScanRes;
  }

  Future<void> barkodGonder(BuildContext context, String barcode) async {
    try {
      final response = await HttpBuildService.sendRequest(
          'GET', 'api/barcodes/code/$barcode',
          token: true);
      if (response.statusCode == 200) {
        BarcodeJson veri =
            BarcodeJson.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        bool confirmed = await _showBarcodeDialog(context, veri.name!);
        if (confirmed) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BarcodeScanResult(barcode: veri)));
        } else {
          _showSnackBar(context, 'Tekrar taramayı deneyin!');
        }
      } else {
        await _showCorrectBarcodeModal(context, barcode);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> _showBarcodeDialog(
      BuildContext context, String productName) async {
    return (await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Barkod Taraması'),
              content: Text('Ürün: $productName'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Hayır')),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Evet')),
              ],
            );
          },
        )) ??
        false;
  }

  Future<void> _showCorrectBarcodeModal(
      BuildContext context, String barcode) async {
    TextEditingController barcodeController =
        TextEditingController(text: barcode);
    bool confirmed = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 10,
                right: 10,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Barkod Kontrolü"),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: barcodeController,
                      keyboardType: TextInputType.number,
                      maxLength: 13,
                      decoration: const InputDecoration(
                        labelText: "Barkod",
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('İptal')),
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Devam Et')),
                    ],
                  ),
                ],
              ),
            );
          },
        ) ??
        false;

    if (confirmed) {
      await _validateAndSubmitBarcode(context, barcodeController.text);
    }
  }

  Future<void> _validateAndSubmitBarcode(
      BuildContext context, String correctedBarcode) async {
    try {
      final response = await HttpBuildService.sendRequest(
          'GET', 'api/barcodes/code/$correctedBarcode',
          token: true);
      if (response.statusCode == 200) {
        BarcodeJson veri =
            BarcodeJson.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        bool confirmed = await _showBarcodeDialog(context, veri.name!);
        if (confirmed) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BarcodeScanResult(barcode: veri)));
        } else {
          _showSnackBar(context, 'Tekrar taramayı deneyin!');
        }
      } else {
        await _showProductNotFoundDialog(context);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showProductNotFoundDialog(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ürün Bulunamadı'),
          content: const Text(
              'Tarattığınız barkod bulunamadı. Bize bu ürünü önermek ister misiniz?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('İptal')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showSuggestionModal(context);
                },
                child: const Text('Öner')),
          ],
        );
      },
    );
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
          print('Failed to load image. Status code: ${response.statusCode}');
        }
      }
    }
  }

  Widget _buildReceiptCard(ReceiptJson receipt) {
    String imageUrl =
        "https://api.colyakdiyabet.com.tr/api/image/get/${receipt.imageId}";

    return GestureDetector(
      onTap: () {
        if (imageBytesMap.containsKey(imageUrl)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptDetailScreen(
                receipt: receipt,
                imageBytes: imageBytesMap[imageUrl]!,
              ),
            ),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageBytesMap.containsKey(imageUrl))
              Expanded(
                flex: 7,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8)),
                  child: Image.memory(
                    imageBytesMap[imageUrl]!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              )
            else
              Expanded(
                flex: 7,
                child: Shimmer(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey.shade300,
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  DrawerHeader(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: Image.asset("assets/images/colyak.png"))
                      ],
                    ),
                  ),
                  _buildDrawerItem(Icons.document_scanner, 'Bolus Raporları',
                      (context) => const BolusReportScreen()),
                  _buildDrawerItem(
                      Icons.quiz, 'Quizler', (context) => const QuizScreen()),
                  _buildDrawerItem(Icons.tips_and_updates, 'Öneri Yap',
                      (context) => const Suggestion()),
                  _buildDrawerItem(Icons.menu_book, 'Faydalı Bilgiler',
                      (context) => const UserGuides()),
                  _buildDrawerItem(Icons.settings, 'Ayarlar',
                      (context) => const SettingsScreen()),
                  _buildDrawerItem(Icons.logout, 'Çıkış Yap', (context) {
                    Navigator.pop(context);
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          "/loginscreen", (Route<dynamic> route) => false);
                    });
                    return Container();
                  }),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('© 2024 Çölyak Hastaları',
                  style: TextStyle(fontSize: 12, color: Colors.black87)),
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
                child: FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person, size: 48),
                      Text(" Hoş geldin, \n ${HttpBuildService.userName}",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10, bottom: 5, top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Neler yapılabilir?", style: TextStyle(fontSize: 18))
                  ],
                ),
              ),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
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
                                  Text("Hazır gıdalar için barkod tarayıcı")),
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
                    child: Text("En Çok Tercih Edilen 5 Tarif",
                        style: TextStyle(fontSize: 18)),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3.7,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1),
                      controller: _scrollController,
                      itemCount: receipts.length,
                      itemBuilder: (context, index) {
                        return _buildReceiptCard(receipts[index]);
                      },
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Öğün Ekle", style: TextStyle(fontSize: 18)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MealScreen()));
                    },
                    child: const Card(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: ListTile(
                          title: Text("Öğün Listem"),
                          subtitle: Text(
                              "Bolus hesaplamak için yediklerini seçip öğün listeni oluştur"),
                          leading: Icon(Icons.fastfood),
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

  Widget _buildDrawerItem(
      IconData icon, String title, Widget Function(BuildContext) builder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: builder));
        },
      ),
    );
  }

  Widget _buildArrowButton(IconData icon, bool isVisible, int direction) {
    return IconButton(
      icon: Icon(icon),
      onPressed: isVisible
          ? () {
              _scrollController.animateTo(
                _scrollController.offset +
                    (MediaQuery.of(context).size.width * direction),
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            }
          : null,
    );
  }

  void _showSuggestionModal(BuildContext context) {
    TextEditingController suggestionController = TextEditingController();
    showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 10,
              right: 10,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Ürün Önerisi Yap"),
                const Divider(),
                Text("Barkod: $barcodeScanRes"),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: suggestionController,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      labelText: "Ürün İsmi",
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('İptal')),
                    TextButton(
                        onPressed: () {
                          suggestionGonder(
                              "$barcodeScanRes | ${suggestionController.text}");
                        },
                        child: const Text('Gönder')),
                  ],
                ),
              ],
            ),
          );
        });
  }

  void suggestionGonder(String suggestion) async {
    try {
      final suggestionDetails = {'suggestion': suggestion};
      final response = await HttpBuildService.sendRequest(
        'POST',
        'api/suggestions/add',
        body: suggestionDetails,
        token: true,
      );

      if (response.statusCode == 200) {
        _showSnackBar(context, 'Ürün önerisi gönderildi!');
        Navigator.pop(context);
      } else {
        _showSnackBar(context, 'Ürün önerilirken hata!',
            additionalMessage: response.statusCode.toString());
      }
    } catch (e) {
      print(e);
    }
  }

  void _showSnackBar(BuildContext context, String message,
      {String? additionalMessage}) {
    final snackBar = SnackBar(
      content: Text('$message ${additionalMessage ?? ''}'),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
