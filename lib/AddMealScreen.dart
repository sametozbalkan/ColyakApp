import 'package:colyakapp/BarcodeJson.dart';
import 'package:colyakapp/BolusJson.dart';
import 'package:colyakapp/MealDetailScreen.dart';
import 'package:colyakapp/ReceiptJson.dart';
import 'package:flutter/material.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

List<ReceiptJson> receiptsMeal = [];
List<BarcodeJson> barcodesMeal = [];

class _AddMealScreenState extends State<AddMealScreen> {
  List<ReceiptJson> filteredReceipts = [];
  List<BarcodeJson> filteredBarcodes = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredReceipts = receiptsMeal;
    filteredBarcodes = barcodesMeal;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void search(String value) {
    final query = value.toLowerCase();
    setState(() {
      filteredReceipts = receiptsMeal
          .where((receipt) =>
              receipt.receiptName?.toLowerCase().contains(query) ?? false)
          .toList();
      filteredBarcodes = barcodesMeal
          .where(
              (barcode) => barcode.name?.toLowerCase().contains(query) ?? false)
          .toList();
    });
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: TextField(
        controller: searchController,
        decoration: const InputDecoration(
          labelText: "Ara",
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: search,
      ),
    );
  }

  Widget _buildListView<T>(
      List<T> items, String Function(T) getName, void Function(T) onTap) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: GestureDetector(
            onTap: () => onTap(item),
            child: ListTile(
              title: Text(getName(item)),
              trailing: const Icon(Icons.arrow_forward),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Öğün Seç")),
      body: Column(
        children: <Widget>[
          _buildSearchField(),
          DefaultTabController(
            length: 2,
            initialIndex: 0,
            child: Expanded(
              child: Column(
                children: <Widget>[
                  const TabBar(
                    indicatorColor: Color(0xFFFF7A37),
                    labelColor: Color(0xFFFF7A37),
                    unselectedLabelColor: Colors.black,
                    tabs: [
                      Tab(text: 'Tarifler'),
                      Tab(text: 'Hazır Gıdalar'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: <Widget>[
                        _buildListView<ReceiptJson>(
                          filteredReceipts,
                          (receipt) => receipt.receiptName!,
                          (receipt) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MealDetailScreen(
                                  receiptOrBarcodes: FoodType.RECEIPT,
                                  receipt: receipt,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildListView<BarcodeJson>(
                          filteredBarcodes,
                          (barcode) => barcode.name!,
                          (barcode) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MealDetailScreen(
                                  receiptOrBarcodes: FoodType.BARCODE,
                                  barcode: barcode,
                                ),
                              ),
                            ).then((value) => setState(() {}));
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
  }
}
