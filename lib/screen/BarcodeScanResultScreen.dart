import 'package:cached_network_image/cached_network_image.dart';
import 'package:colyakapp/model/BarcodeJson.dart';
import 'package:colyakapp/others/Shimmer.dart';
import 'package:colyakapp/viewmodel/BarcodeScanResultViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BarcodeScanResultScreen extends StatelessWidget {
  final BarcodeJson barcode;

  const BarcodeScanResultScreen({super.key, required this.barcode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BarcodeScanResultViewModel(barcode: barcode),
      child: Consumer<BarcodeScanResultViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(viewModel.barcode.name!),
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
                              imageUrl: viewModel.imageUrl,
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
                        _buildInfoRow('Gluten: ',
                            viewModel.barcode.glutenFree! ? 'Var' : 'Yok'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Barkod: ',
                            viewModel.barcode.code.toString()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Besin Değerleri',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildNutritionalValues(viewModel)
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNutritionalValues(BarcodeScanResultViewModel viewModel) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.barcode.nutritionalValuesList?.length,
      itemBuilder: (context, index) {
        final nutritionalValue = viewModel.barcode.nutritionalValuesList![index];
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
