import 'package:colyakapp/BarcodeJson.dart';
import 'package:colyakapp/BolusJson.dart';
import 'package:colyakapp/MealScreen.dart';
import 'package:colyakapp/ReceiptJson.dart';
import 'package:flutter/material.dart';

List<FoodListComplex> foodListComplex = [];

class MealDetailScreen extends StatefulWidget {
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
  _MealDetailScreenState createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  int _quantity = 1;
  String? _selectedType;
  double _totalCarbohydrate = 0;
  double _totalCalories = 0;
  double _totalProtein = 0;
  double _totalFat = 0;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.receiptOrBarcodes == FoodType.RECEIPT
        ? (widget.receipt?.nutritionalValuesList?.isEmpty ?? true
            ? null
            : widget.receipt!.nutritionalValuesList!.first.type)
        : (widget.barcode?.nutritionalValuesList?.isEmpty ?? true
            ? null
            : widget.barcode!.nutritionalValuesList!.first.type);
    _calculateNutritionalValues();
  }

  void _calculateNutritionalValues() {
    if (_selectedType == null ||
        (widget.receipt == null && widget.barcode == null)) {
      setState(() {
        _totalCarbohydrate = 0;
        _totalCalories = 0;
        _totalProtein = 0;
        _totalFat = 0;
      });
    } else {
      double totalCarb = 0;
      double totalCalories = 0;
      double totalProtein = 0;
      double totalFat = 0;

      var nutritionalValuesList = widget.receiptOrBarcodes == FoodType.RECEIPT
          ? widget.receipt!.nutritionalValuesList!
          : widget.barcode!.nutritionalValuesList!;

      for (var item in nutritionalValuesList) {
        if (item.type == _selectedType) {
          totalCarb += item.carbohydrateAmount ?? 0;
          totalCalories += item.calorieAmount ?? 0;
          totalProtein += item.proteinAmount ?? 0;
          totalFat += item.fatAmount ?? 0;
        }
      }

      setState(() {
        _totalCarbohydrate = totalCarb * _quantity;
        _totalCalories = totalCalories * _quantity;
        _totalProtein = totalProtein * _quantity;
        _totalFat = totalFat * _quantity;
      });
    }
  }

  void _addOrUpdateFoodList() {
    var foodId = widget.barcode?.id ?? widget.receipt?.id;
    var foodName = widget.barcode?.name ?? widget.receipt?.receiptName;

    if (foodId == null || foodName == null || _selectedType == null) {
      return;
    }

    var existingItemIndex = foodListComplex.indexWhere(
      (element) => element.foodId == foodId && element.type == _selectedType,
    );

    if (existingItemIndex != -1) {
      setState(() {
        foodListComplex[existingItemIndex].amount =
            (foodListComplex[existingItemIndex].amount ?? 0) + _quantity;
        foodListComplex[existingItemIndex].carbonhydrate =
            (foodListComplex[existingItemIndex].carbonhydrate ?? 0) +
                _totalCarbohydrate;
      });

      var existingBolusItemIndex = bolusFoodList.indexWhere(
        (element) => element.foodId == foodId,
      );
      if (existingBolusItemIndex != -1) {
        setState(() {
          bolusFoodList[existingBolusItemIndex].carbonhydrate =
              (bolusFoodList[existingBolusItemIndex].carbonhydrate ?? 0) +
                  _totalCarbohydrate;
        });
      }
    } else {
      FoodListComplex _foodListComplex = FoodListComplex(
        carbonhydrate: _totalCarbohydrate,
        foodId: foodId,
        foodName: foodName,
        foodType: widget.receiptOrBarcodes.name,
        type: _selectedType,
        amount: _quantity,
      );

      FoodList newItem = FoodList(
        foodType: widget.receiptOrBarcodes.name,
        foodId: foodId,
        carbonhydrate: _totalCarbohydrate,
      );

      setState(() {
        foodListComplex.add(_foodListComplex);
        bolusFoodList.add(newItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.receipt?.receiptName ?? widget.barcode?.name ?? "")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedType != null &&
              (widget.receipt != null || widget.barcode != null)) {
            _addOrUpdateFoodList();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Listeye eklendi!'),
                duration: Duration(seconds: 1),
              ),
            );
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
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Besin Değerleri:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text("Kalori: ${_totalCalories.toStringAsFixed(2)} kcal",
                    style: const TextStyle(fontSize: 16)),
                Text(
                  "Karbonhidrat: ${_totalCarbohydrate.toStringAsFixed(2)} g",
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "Protein: ${_totalProtein.toStringAsFixed(2)} g",
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "Yağ: ${_totalFat.toStringAsFixed(2)} g",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Miktar:",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (_quantity > 1) {
                    setState(() {
                      _quantity--;
                    });
                    _calculateNutritionalValues();
                  }
                },
              ),
              Text(
                " $_quantity",
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _quantity++;
                  });
                  _calculateNutritionalValues();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Tür Seçin:",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(height: 40, child: _buildTypeButtons()),
          ),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Öğün Listem",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              key: widget.key,
              shrinkWrap: true,
              itemCount: foodListComplex.length,
              itemBuilder: (context, index) {
                FoodListComplex foodItem = foodListComplex[index];
                return ListTile(
                  title: Text(
                      "${foodItem.amount} x ${foodItem.type} ${foodItem.foodName!}"),
                  subtitle: Text(
                      'Karbonhidrat: ${foodItem.carbonhydrate?.toStringAsFixed(2)} gram'),
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        foodListComplex.removeAt(index);
                        bolusFoodList.removeAt(index);
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
          )
        ],
      ),
    );
  }

  Widget _buildTypeButtons() {
    var nutritionalValuesList = widget.receiptOrBarcodes == FoodType.RECEIPT
        ? widget.receipt?.nutritionalValuesList ?? []
        : widget.barcode?.nutritionalValuesList ?? [];

    return ListView.separated(
      separatorBuilder: (context, index) {
        return const SizedBox(width: 5);
      },
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount: nutritionalValuesList.length,
      itemBuilder: (context, index) {
        var item = nutritionalValuesList[index];
        return ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedType = item.type;
            });
            _calculateNutritionalValues();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedType == item.type
                ? const Color(0xFFFF7A37)
                : Colors.white,
          ),
          child: Text(
            item.type ?? "",
            style: TextStyle(
              color: _selectedType == item.type
                  ? Colors.white
                  : const Color(0xFFFF7A37),
            ),
          ),
        );
      },
    );
  }
}
