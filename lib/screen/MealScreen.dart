import 'package:colyakapp/model/BarcodeJson.dart';
import 'package:colyakapp/model/BolusJson.dart';
import 'package:colyakapp/model/ReceiptJson.dart';
import 'package:colyakapp/screen/AddMealScreen.dart';
import 'package:colyakapp/screen/BolusScreen.dart';
import 'package:colyakapp/viewmodel/MealViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MealScreen extends StatelessWidget {
  final List<FoodListComplex> foodListComplex;
  final List<ReceiptJson> receiptList;
  final List<BarcodeJson> barkodList;
  const MealScreen(
      {super.key,
      required this.foodListComplex,
      required this.receiptList,
      required this.barkodList});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MealViewModel()..initializeData(foodListComplex),
      child: Consumer<MealViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back)),
              title: const Text("Öğün Listem"),
              actions: [
                IconButton(
                  onPressed: () async {
                    final response = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMealScreen(
                            receiptList: receiptList, barkodList: barkodList),
                      ),
                    );

                    if (response != null && response is List<FoodListComplex>) {
                      viewModel.addItemsToFoodList(response);
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              viewModel.totalCarb.toStringAsFixed(2),
                              style: const TextStyle(fontSize: 40),
                            ),
                            const Text("g"),
                          ],
                        ),
                        const Text("Toplam Karbonhidrat Miktarı"),
                      ],
                    ),
                  ),
                  viewModel.foodListComplex.isNotEmpty
                      ? ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BolusScreen(totalCarb: viewModel.totalCarb),
                              ),
                            ).then((onValue) {
                              viewModel.totalCarb == 0
                                  ? viewModel.reset()
                                  : null;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          child: const Text("Bolus Hesapla"),
                        )
                      : Container(),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Öğün Listem",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Ekstra Karbonhidrat Ekle'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  TextEditingController carbController =
                                      TextEditingController();
                                  return AlertDialog(
                                    title: const Text('Karbonhidrat Ekle'),
                                    content: TextField(
                                      controller: carbController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        hintText: 'g',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('İptal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          double? newCarb = double.tryParse(
                                              carbController.text);
                                          if (newCarb != null) {
                                            viewModel.addManualCarb(newCarb);
                                          }
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Kaydet'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const Divider(),
                        viewModel.foodListComplex.isEmpty
                            ? const Expanded(
                                child: Center(
                                    child: Text('Öğün Listenize Ekleme Yapın')))
                            : Expanded(
                                child: ListView.builder(
                                  itemCount: viewModel
                                          .foodListComplex.isNotEmpty
                                      ? viewModel.foodListComplex.length * 2 - 1
                                      : 0,
                                  itemBuilder: (context, index) {
                                    if (index.isOdd) {
                                      return const Divider(
                                          endIndent: 10, indent: 10);
                                    }
                                    int itemIndex = index ~/ 2;
                                    FoodListComplex foodItem =
                                        viewModel.foodListComplex[itemIndex];
                                    return Dismissible(
                                      key: UniqueKey(),
                                      direction: DismissDirection.startToEnd,
                                      onDismissed: (direction) {
                                        viewModel.removeFood(foodItem);
                                      },
                                      background: Container(
                                        color: Colors.red,
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: const Icon(Icons.delete,
                                            color: Colors.white),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                            "${foodItem.amount} x ${foodItem.type} ${foodItem.foodName!}"),
                                        subtitle: Text(
                                            'Karbonhidrat: ${foodItem.carbonhydrate?.toStringAsFixed(2)} gram'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () {
                                                if (foodItem.amount! > 1) {
                                                  viewModel.updateCarb(
                                                      foodItem, -1);
                                                } else {
                                                  viewModel
                                                      .removeFood(foodItem);
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () {
                                                viewModel.updateCarb(
                                                    foodItem, 1);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
