import 'package:colyakapp/BolusJson.dart';
import 'package:colyakapp/MealDetailScreen.dart';
import 'package:colyakapp/ReceiptReadyFoodsJson.dart';
import 'package:flutter/material.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

List<ReceiptJson> receiptsMeal = [];
List<ReadyFoodsJson> readyfoodsMeal = [];

class _AddMealScreenState extends State<AddMealScreen> {
  List<ReceiptJson> filteredReceipts = [];
  List<ReadyFoodsJson> filteredReadyFoods = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredReceipts = receiptsMeal;
    filteredReadyFoods = readyfoodsMeal;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void search(String value) {
    String query = value.toLowerCase();
    setState(() {
      filteredReceipts = receiptsMeal
          .where(
              (receipt) => receipt.receiptName!.toLowerCase().contains(query))
          .toList();
      filteredReadyFoods = readyfoodsMeal
          .where((readyFood) =>
              readyFood.readyFoodName!.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Öğün Seç")),
      body: Column(
        children: <Widget>[
          Padding(
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
          ),
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
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredReceipts.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MealDetailScreen(
                                          receiptOrReadyFoods: FoodType.RECEIPT,
                                          receipt: filteredReceipts[index]),
                                    ),
                                  );
                                },
                                child: ListTile(
                                    title: Text(
                                        filteredReceipts[index].receiptName!),
                                    trailing: const Icon(Icons.arrow_forward)),
                              ),
                            );
                          },
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredReadyFoods.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MealDetailScreen(
                                        receiptOrReadyFoods: FoodType.READYFOOD,
                                        readyFoods: filteredReadyFoods[index],
                                      ),
                                    ),
                                  ).then((value) => setState(() {}));
                                },
                                child: ListTile(
                                    title: Text(filteredReadyFoods[index]
                                        .readyFoodName!),
                                    trailing: const Icon(Icons.arrow_forward)),
                              ),
                            );
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
