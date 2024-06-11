import 'package:colyakapp/model/BolusJson.dart';
import 'package:colyakapp/viewmodel/AddMealViewModel.dart';
import 'package:flutter/material.dart';
import 'package:colyakapp/model/BarcodeJson.dart';
import 'package:colyakapp/model/FoodType.dart';
import 'package:colyakapp/model/ReceiptJson.dart';
import 'package:provider/provider.dart';

import 'MealDetailScreen.dart';

class AddMealScreen extends StatelessWidget {
  const AddMealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddMealViewModel()..initializeData(),
      child: Consumer<AddMealViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(title: const Text("Öğün Seç")),
            body: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: TextField(
                    controller: TextEditingController(),
                    decoration: const InputDecoration(
                      labelText: "Ara",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => viewModel.search(value),
                  ),
                ),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration:
                              const BoxDecoration(color: Color(0xFFFFF1EC)),
                          child: const TabBar(
                            indicatorColor: Color(0xFFFF7A37),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.black,
                            tabs: [
                              Tab(text: 'Tarifler'),
                              Tab(text: 'Hazır Gıdalar'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: <Widget>[
                              _buildListView<ReceiptJson>(
                                viewModel.filteredReceipts,
                                (receipt) => receipt.receiptName!,
                                (receipt) {
                                  _showMealDetailScreen(
                                    context,
                                    FoodType.RECEIPT,
                                    viewModel.foodListComplex,
                                    receipt: receipt,
                                  );
                                },
                              ),
                              _buildListView<BarcodeJson>(
                                viewModel.filteredBarcodes,
                                (barcode) => barcode.name!,
                                (barcode) {
                                  _showMealDetailScreen(
                                      context,
                                      FoodType.BARCODE,
                                      viewModel.foodListComplex,
                                      barcode: barcode);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView<T>(
      List<T> items, String Function(T) getName, void Function(T) onTap) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => onTap(item),
          child: ListTile(
            title: Text(getName(item)),
            trailing: const Icon(Icons.arrow_forward),
          ),
        );
      },
    );
  }

  void _showMealDetailScreen(BuildContext context, FoodType type,
      List<FoodListComplex> foodListComplex,
      {ReceiptJson? receipt, BarcodeJson? barcode}) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 10,
            right: 10,
            top: 20,
          ),
          child: MealDetailScreen(
            receiptOrBarcodes: type,
            receipt: receipt,
            barcode: barcode,
          ),
        );
      },
    ).then((selectedItems) {
      if (selectedItems != null) {
        Navigator.of(context).pop(selectedItems);
      }
    });
  }
}
