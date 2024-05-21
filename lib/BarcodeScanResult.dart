import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'BarcodeJson.dart';

class BarcodeScanResult extends StatefulWidget {
  final BarcodeJson barcode;

  const BarcodeScanResult({super.key, required this.barcode});

  @override
  _BarcodeScanResultState createState() => _BarcodeScanResultState();
}

class _BarcodeScanResultState extends State<BarcodeScanResult> {
  Map<String, Uint8List?> imageBytesMap = {};
  String imageUrl = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadImageBytes();
  }

  Future<void> _loadImageBytes() async {
    setState(() {
      isLoading = true;
    });

    int imageId = widget.barcode.imageId!;
    imageUrl = "https://api.colyakdiyabet.com.tr/api/image/get/$imageId";
    if (!imageBytesMap.containsKey(imageUrl)) {
      var response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        setState(() {
          imageBytesMap[imageUrl] = response.bodyBytes;
          isLoading = false;
        });
      } else {
        print('Resim alınamadı. Hata kodu: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.barcode.name!),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageBytesMap.containsKey(imageUrl))
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          child: Image.memory(
                            imageBytesMap[imageUrl]!,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Gluten: ',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(widget.barcode.glutenFree! ? 'Var' : 'Yok',
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Barkod: ',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(widget.barcode.code.toString(),
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Besin Değerleri',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.barcode.nutritionalValuesList!.length,
                      itemBuilder: (context, index) {
                        final value =
                            widget.barcode.nutritionalValuesList![index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Column(
                              children: [
                                Text("${value.unit} ${value.type}"),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Kalori (kcal):"),
                                    Text(
                                      value.calorieAmount.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Karbonhidrat (g):"),
                                    Text(
                                      value.carbohydrateAmount.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Yağ (g):"),
                                    Text(
                                      value.fatAmount.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Protein (g):"),
                                    Text(
                                      value.proteinAmount.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
