import 'dart:convert';
import 'dart:typed_data';
import 'package:colyakapp/screen/BarcodeScanResultScreen.dart';
import 'package:flutter/material.dart';
import 'package:colyakapp/model/ReceiptJson.dart';
import 'package:colyakapp/model/BarcodeJson.dart';
import 'package:colyakapp/cachemanager/CacheManager.dart';
import 'package:colyakapp/service/HttpBuild.dart';

class HomeViewModel extends ChangeNotifier {
  List<ReceiptJson> receipts = [];
  Map<String, Uint8List?> imageBytesMap = {};
  List<ReceiptJson> receiptsMeal = [];
  List<BarcodeJson> barcodesMeal = [];
  Set<String> loadedImages = {};

  HomeViewModel() {
    initializeData();
  }

  Future<void> _fetchReceipts() async {
    var response = await HttpBuildService.sendRequest(
        "GET", "api/receipts/getAll/all",
        token: true);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    receiptsMeal = data.map((json) => ReceiptJson.fromJson(json)).toList();
    notifyListeners();
  }

  Future<void> _fetchBarcodes() async {
    var response = await HttpBuildService.sendRequest("GET", "api/barcodes/all",
        token: true);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    barcodesMeal = data.map((json) => BarcodeJson.fromJson(json)).toList();
    notifyListeners();
  }

  Future<void> _loadCachedImages() async {
    for (ReceiptJson receipt in receipts) {
      String imageUrl =
          "https://api.colyakdiyabet.com.tr/api/image/get/${receipt.imageId}";
      Uint8List? imageBytes = await CacheManager().getImageBytes(imageUrl);
      if (imageBytes != null) {
        imageBytesMap[imageUrl] = imageBytes;
      }
    }
    notifyListeners();
  }

  Future<void> _fetchImage(String imageUrl) async {
    Uint8List? imageBytes = await CacheManager().getImageBytes(imageUrl);
    if (imageBytes != null) {
      imageBytesMap[imageUrl] = imageBytes;
      loadedImages.add(imageUrl);
      notifyListeners();
    }
  }

  Future<void> _loadImagesInBackground(List<ReceiptJson> receipts) async {
    await Future.delayed(const Duration(milliseconds: 100), () async {
      for (int i = 0; i < receipts.length; i++) {
        String imageUrl =
            "https://api.colyakdiyabet.com.tr/api/image/get/${receipts[i].imageId}";
        if (!loadedImages.contains(imageUrl)) {
          await _fetchImage(imageUrl);
        }
      }
    });
    notifyListeners();
  }

  Future<void> initializeData() async {
    try {
      await Future.wait(
          [_fetchTop5Receipts(), _fetchReceipts(), _fetchBarcodes()]);
      _loadCachedImages();
      _loadImagesInBackground(receipts);
      notifyListeners();
    } catch (e) {
      debugPrint("Error initializing data: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> _fetchTop5Receipts() async {
    var response = await HttpBuildService.sendRequest(
        "GET", "api/meals/report/top5receipts",
        token: true);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    receipts = data.map((json) => ReceiptJson.fromJson(json)).toList();
    notifyListeners();
  }

  Future<void> sendBarcode(BuildContext context, String barcode) async {
    try {
      final response = await HttpBuildService.sendRequest(
          'GET', 'api/barcodes/code/$barcode',
          token: true);
      if (response.statusCode == 200) {
        BarcodeJson data =
            BarcodeJson.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        bool confirmed = await showBarcodeDialog(context, data.name!);
        if (confirmed) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BarcodeScanResultScreen(barcode: data),
            ),
          );
        } else {
          showSnackBar(context, 'Tekrar taramayı deneyin!');
        }
      } else {
        await showCorrectBarcodeModal(context, barcode);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> showBarcodeDialog(
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

  Future<void> showCorrectBarcodeModal(
      BuildContext context, String barcode) async {
    TextEditingController barcodeController =
        TextEditingController(text: barcode);
    bool confirmed = await showModalBottomSheet<bool>(
          backgroundColor: Colors.white,
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
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10, top: 10),
                    child: Text("Barkod Kontrolü"),
                  ),
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
      await validateAndSubmitBarcode(context, barcodeController.text);
    }
  }

  Future<void> validateAndSubmitBarcode(
      BuildContext context, String correctedBarcode) async {
    try {
      final response = await HttpBuildService.sendRequest(
          'GET', 'api/barcodes/code/$correctedBarcode',
          token: true);
      if (response.statusCode == 200) {
        BarcodeJson data =
            BarcodeJson.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        bool confirmed = await showBarcodeDialog(context, data.name!);
        if (confirmed) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BarcodeScanResultScreen(barcode: data),
            ),
          );
        } else {
          showSnackBar(context, 'Tekrar taramayı deneyin!');
        }
      } else {
        await showProductNotFoundDialog(context, correctedBarcode);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> showProductNotFoundDialog(
      BuildContext context, String barcodeScanRes) async {
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
                  showSuggestionModal(context,
                      isProductSuggestion: true,
                      barcodeScanRes: barcodeScanRes);
                },
                child: const Text('Öner')),
          ],
        );
      },
    );
  }

  void showSuggestionModal(BuildContext context,
      {bool isProductSuggestion = false, String barcodeScanRes = ""}) {
    TextEditingController suggestionController = TextEditingController();
    showModalBottomSheet(
        backgroundColor: Colors.white,
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
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 10, top: 10),
                  child: Text("Öneri Yap"),
                ),
                const Divider(),
                if (isProductSuggestion)
                  Text("Barkod: $barcodeScanRes")
                else
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Diyetisyeninize önermek istediğiniz bir ürün veya tarif mi var? Aşağıdaki boş alana önerinizi yazıp gönderebilirsiniz.",
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: suggestionController,
                    maxLength: 100,
                    decoration: InputDecoration(
                      labelText:
                          isProductSuggestion ? "Ürün İsmi" : "Önerinizi yazın",
                      counterText: '',
                      border: const OutlineInputBorder(),
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
                          final suggestionText = isProductSuggestion
                              ? "$barcodeScanRes | ${suggestionController.text}"
                              : suggestionController.text;
                          sendSuggestion(
                              context, suggestionText, isProductSuggestion);
                        },
                        child: const Text('Gönder')),
                  ],
                ),
              ],
            ),
          );
        });
  }

  Future<void> sendSuggestion(
      BuildContext context, String suggestion, bool isProductSuggestion) async {
    try {
      final suggestionDetails = {'suggestion': suggestion};
      final response = await HttpBuildService.sendRequest(
        'POST',
        'api/suggestions/add',
        body: suggestionDetails,
        token: true,
      );

      if (response.statusCode == 200) {
        showSnackBar(
            context,
            isProductSuggestion
                ? 'Ürün önerisi gönderildi!'
                : 'Öneri gönderildi!');
        Navigator.pop(context);
      } else {
        showSnackBar(context, 'Öneri gönderilirken hata!',
            additionalMessage: response.statusCode.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void showSnackBar(BuildContext context, String message,
      {String? additionalMessage}) {
    final snackBar = SnackBar(
      content: Text(
          message + (additionalMessage != null ? ' $additionalMessage' : '')),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
