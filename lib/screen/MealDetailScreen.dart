import 'package:colyakapp/viewmodel/MealDetailViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:colyakapp/model/BarcodeJson.dart';
import 'package:colyakapp/model/FoodType.dart';
import 'package:colyakapp/model/ReceiptJson.dart';

class MealDetailScreen extends StatelessWidget {
  final FoodType receiptOrBarcodes;
  final ReceiptJson? receipt;
  final BarcodeJson? barcode;

  const MealDetailScreen({
    super.key,
    required this.receiptOrBarcodes,
    this.receipt,
    this.barcode,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MealDetailViewModel(
        receiptOrBarcodes: receiptOrBarcodes,
        receipt: receipt,
        barcode: barcode,
      ),
      child: Consumer<MealDetailViewModel>(
        builder: (context, viewModel, child) {
          return Column(
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
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  viewModel.receipt?.receiptName ??
                      viewModel.barcode?.name ??
                      "",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        const Text(
                          "Besin Değerleri",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Kalori: ${viewModel.totalCalories.toStringAsFixed(2)} kcal",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          "K.hidrat: ${viewModel.totalCarbohydrate.toStringAsFixed(2)} g",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Protein: ${viewModel.totalProtein.toStringAsFixed(2)} g",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Yağ: ${viewModel.totalFat.toStringAsFixed(2)} g",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Text(
                        "Miktar",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (viewModel.quantity > 1) {
                                  viewModel.setQuantity(viewModel.quantity - 1);
                                }
                              },
                            ),
                            SizedBox(
                              width: 40,
                              height: 50,
                              child: TextFormField(
                                controller: viewModel.quantityController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                onChanged: (value) {
                                  if (value.isNotEmpty &&
                                      viewModel.totalCarbohydrate != 0) {
                                    viewModel.setQuantity(int.parse(value));
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                viewModel.setQuantity(viewModel.quantity + 1);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  "Tür Seçin",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                    height: 40, child: _buildDropdownButton(viewModel)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (viewModel.selectedType != null &&
                      (viewModel.receipt != null ||
                          viewModel.barcode != null) &&
                      viewModel.quantity != 0) {
                    viewModel.addOrUpdateFoodList();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Listeye eklendi!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    Navigator.of(context).pop(viewModel.foodListComplex);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Lütfen bir tür seçin!',
                        ),
                      ),
                    );
                  }
                },
                child: const Text("Öğün Listesine Ekle"),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdownButton(MealDetailViewModel viewModel) {
    var nutritionalValuesList = viewModel.receiptOrBarcodes == FoodType.RECEIPT
        ? viewModel.receipt?.nutritionalValuesList ?? []
        : viewModel.barcode?.nutritionalValuesList ?? [];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 5),
        child: DropdownButton<String>(
          underline: Container(),
          borderRadius: BorderRadius.circular(5),
          alignment: Alignment.center,
          value: viewModel.selectedType,
          onChanged: (newValue) {
            viewModel.setSelectedType(newValue);
          },
          items: nutritionalValuesList.map((item) {
            return DropdownMenuItem<String>(
              alignment: Alignment.center,
              value: item.type,
              child: Text(item.type ?? "", overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        ),
      ),
    );
  }
}
