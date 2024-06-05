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

class _MealScreenState extends State<MealScreen> {
  double totalCarb = 0;
  double _totalCarb = 0;

  @override
  void initState() {
    super.initState();
    totalCarb = 0;
    _totalCarb = 0;
    carbHesapla();
  }

  void carbHesapla() {
    _totalCarb = 0;
    for (var item in bolusFoodList) {
      _totalCarb += item.carbonhydrate ?? 0.0;
    }
    setState(() {
      totalCarb = _totalCarb;
    });
  }

  void _updateCarb(FoodListComplex foodItem, int quantityChange) {
    setState(() {
      int currentAmount = foodItem.amount ?? 0;
      double currentCarb = foodItem.carbonhydrate ?? 0.0;

      int newAmount = currentAmount + quantityChange;
      double newCarb =
          currentCarb + (currentCarb / currentAmount) * quantityChange;

      if (newAmount <= 0) {
        foodListComplex.remove(foodItem);
        bolusFoodList
            .removeWhere((element) => element.foodId == foodItem.foodId);
      } else {
        foodItem.amount = newAmount;
        foodItem.carbonhydrate = newCarb;

        var bolusItemIndex = bolusFoodList.indexWhere(
          (element) => element.foodId == foodItem.foodId,
        );

        if (bolusItemIndex != -1) {
          double bolusCarb = bolusFoodList[bolusItemIndex].carbonhydrate ?? 0.0;
          bolusFoodList[bolusItemIndex].carbonhydrate =
              bolusCarb + (bolusCarb / currentAmount) * quantityChange;
        } else {
          bolusFoodList.add(FoodList(
            foodType: foodItem.type,
            foodId: foodItem.foodId,
            carbonhydrate: newCarb,
          ));
        }
      }
      carbHesapla();
      karbonhidratMiktariController.text = totalCarb.toStringAsFixed(2);
    });
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
                        totalCarb.toStringAsFixed(2),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Expanded(
              child: foodListComplex.isEmpty
                  ? const Center(
                      child: Text("Sağ üstten yediklerinizi ekleyin.",
                          softWrap: true, textAlign: TextAlign.center))
                  : ListView.builder(
                      itemCount: foodListComplex.length * 2 - 1,
                      itemBuilder: (context, index) {
                        if (index.isOdd) {
                          return const Divider(endIndent: 10, indent: 10);
                        }
                        int itemIndex = index ~/ 2;
                        FoodListComplex foodItem = foodListComplex[itemIndex];
                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (direction) {
                            setState(() {
                              foodListComplex.removeAt(itemIndex);
                              bolusFoodList.removeWhere((element) =>
                                  element.foodId == foodItem.foodId &&
                                  element.carbonhydrate ==
                                      foodItem.carbonhydrate);
                              carbHesapla();
                              karbonhidratMiktariController.text =
                                  totalCarb.toStringAsFixed(2);
                            });
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
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
                                    if (foodItem.amount! >= 1) {
                                      _updateCarb(foodItem, -1);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    _updateCarb(foodItem, 1);
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
  }
}
