import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'Shimmer.dart';
import 'BarcodeJson.dart';

class BarcodeScanResult extends StatefulWidget {
  final BarcodeJson barcode;

  const BarcodeScanResult({super.key, required this.barcode});

  @override
  _BarcodeScanResultState createState() => _BarcodeScanResultState();
}

class _BarcodeScanResultState extends State<BarcodeScanResult> {
  late String imageUrl;

  @override
  void initState() {
    super.initState();
    imageUrl =
        "https://api.colyakdiyabet.com.tr/api/image/get/${widget.barcode.imageId}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.barcode.name!),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        placeholder: (context, url) => Shimmer(
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      'Gluten: ', widget.barcode.glutenFree! ? 'Var' : 'Yok'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Barkod: ', widget.barcode.code.toString()),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Besin Değerleri',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            _buildNutritionalValues()
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionalValues() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.barcode.nutritionalValuesList?.length,
      itemBuilder: (context, index) {
        final nutritionalValue = widget.barcode.nutritionalValuesList![index];
        return Card(
          child: ListTile(
            title: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: const Color(0xFFFFF1EC),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 4,
                          height: 30,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFF7A37),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15))),
                        ),
                        Text(
                          nutritionalValue.type ?? "",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          width: 4,
                          height: 30,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFF7A37),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15))),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Kalori (kcal):"),
                    Text(nutritionalValue.calorieAmount.toString()),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Karbonhidrat (g):"),
                    Text(nutritionalValue.carbohydrateAmount.toString()),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Protein (g):"),
                    Text(nutritionalValue.proteinAmount.toString()),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Yağ (g):"),
                    Text(nutritionalValue.fatAmount.toString()),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
