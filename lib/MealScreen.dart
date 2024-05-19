import 'package:colyakapp/BolusScreen.dart';
import 'package:flutter/material.dart';
import 'AddMealScreen.dart';
import 'BolusJson.dart';
import 'MealDetailScreen.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

List<FoodList> bolusFoodList = [];
double totalCarb = 0;
double _totalCarb = 0;

class _MealScreenState extends State<MealScreen> {
  @override
  void initState() {
    super.initState();
    totalCarb = 0;
    _totalCarb = 0;
    carbHesapla();
  }

  void carbHesapla() {
    for (var item in bolusFoodList) {
      _totalCarb += item.carbonhydrate!;
      totalCarb = _totalCarb;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Öğün Ekranı"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddMealScreen(),
                  ),
                ).then((value) => setState(() {
                      totalCarb = 0;
                      _totalCarb = 0;
                      carbHesapla();
                      karbonhidratMiktariController.text =
                          totalCarb.toStringAsFixed(2);
                    }));
              },
              icon: const Icon(Icons.add))
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          foodListComplex.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BolusScreen(),
                      ),
                    );
                  },
                  child: const Text("BOLUS"),
                )
              : const SizedBox(),
          const SizedBox(height: 10),
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
                        totalCarb.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 40),
                      ),
                      const Text("g")
                    ],
                  ),
                  const Text("Toplam Karbonhidrat Miktarı"),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Öğün Listem:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: foodListComplex.isEmpty
                  ? const Center(child: Text("Liste boş"))
                  : ListView.builder(
                      itemCount: foodListComplex.length,
                      itemBuilder: (context, index) {
                        FoodListComplex foodItem = foodListComplex[index];
                        return ListTile(
                          title: Text(
                              "${foodItem.amount} x ${foodItem.type} ${foodItem.foodName!}"),
                          subtitle: Text(
                              'Karbonhidrat: ${foodItem.carbonhydrate} gram'),
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                foodListComplex.removeAt(index);
                                bolusFoodList.removeAt(index);
                                totalCarb = 0;
                                _totalCarb = 0;
                                carbHesapla();
                                karbonhidratMiktariController.text =
                                    totalCarb.toStringAsFixed(2);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Listeden kaldırıldı!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
