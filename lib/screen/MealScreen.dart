import 'package:colyakapp/model/BarcodeJson.dart';
import 'package:colyakapp/model/BolusJson.dart';
import 'package:colyakapp/model/ReceiptJson.dart';
import 'package:colyakapp/screen/AddMealScreen.dart';
import 'package:colyakapp/viewmodel/BolusModel.dart';
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
                    Navigator.pop(context, viewModel.foodListComplex);
                  },
                  icon: const Icon(Icons.arrow_back)),
              title: const Text("Öğün Ekranı"),
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
                      Provider.of<BolusModel>(context, listen: false)
                          .updateTotalCarb(viewModel.totalCarb);
                      Provider.of<BolusModel>(context, listen: false)
                          .updateFoodList(viewModel.foodListComplex);
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
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Öğün Listem",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: viewModel.foodListComplex.isEmpty
                        ? const Center(
                            child: Text("Sağ üstten yediklerinizi ekleyin.",
                                softWrap: true, textAlign: TextAlign.center))
                        : ListView.builder(
                            itemCount: viewModel.foodListComplex.length * 2 - 1,
                            itemBuilder: (context, index) {
                              if (index.isOdd) {
                                return const Divider(endIndent: 10, indent: 10);
                              }
                              int itemIndex = index ~/ 2;
                              FoodListComplex foodItem =
                                  viewModel.foodListComplex[itemIndex];
                              return Dismissible(
                                key: UniqueKey(),
                                direction: DismissDirection.startToEnd,
                                onDismissed: (direction) {
                                  viewModel.removeFood(foodItem);
                                  Provider.of<BolusModel>(context,
                                          listen: false)
                                      .updateTotalCarb(viewModel.totalCarb);
                                  Provider.of<BolusModel>(context,
                                          listen: false)
                                      .updateFoodList(
                                          viewModel.foodListComplex);
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
                                            viewModel.updateCarb(foodItem, -1);
                                            Provider.of<BolusModel>(context,
                                                    listen: false)
                                                .updateTotalCarb(
                                                    viewModel.totalCarb);
                                            Provider.of<BolusModel>(context,
                                                    listen: false)
                                                .updateFoodList(
                                                    viewModel.foodListComplex);
                                          } else {
                                            viewModel.removeFood(foodItem);
                                            Provider.of<BolusModel>(context,
                                                    listen: false)
                                                .updateTotalCarb(
                                                    viewModel.totalCarb);
                                            Provider.of<BolusModel>(context,
                                                    listen: false)
                                                .updateFoodList(
                                                    viewModel.foodListComplex);
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          viewModel.updateCarb(foodItem, 1);
                                          Provider.of<BolusModel>(context,
                                                  listen: false)
                                              .updateTotalCarb(
                                                  viewModel.totalCarb);
                                          Provider.of<BolusModel>(context,
                                                  listen: false)
                                              .updateFoodList(
                                                  viewModel.foodListComplex);
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
          );
        },
      ),
    );
  }
}
