import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:colyakapp/BarcodeJson.dart';
import 'package:colyakapp/BolusJson.dart';
import 'package:colyakapp/MealScreen.dart';
import 'package:colyakapp/ReceiptJson.dart';

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

List<FoodListComplex> foodListComplex = [];

class _MealDetailScreenState extends State<MealDetailScreen> {
  late int _quantity;
  String? _selectedType;
  late double _totalCarbohydrate;
  late double _totalCalories;
  late double _totalProtein;
  late double _totalFat;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantity = 1;
    _selectedType = widget.receiptOrBarcodes == FoodType.RECEIPT
        ? widget.receipt?.nutritionalValuesList?.first.type
        : widget.barcode?.nutritionalValuesList?.first.type;
    _totalCarbohydrate = 0;
    _totalCalories = 0;
    _totalProtein = 0;
    _totalFat = 0;
    _quantityController = TextEditingController(text: "1");
    _calculateNutritionalValues();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _calculateNutritionalValues() {
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
          child: Text(widget.receipt?.receiptName ?? widget.barcode?.name ?? "",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                    "Kalori: ${_totalCalories.toStringAsFixed(2)} kcal",
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    "K.hidrat: ${_totalCarbohydrate.toStringAsFixed(2)} g",
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
            Column(
              children: [
                const Text(
                  "Miktar",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (_quantity > 1) {
                              _quantity--;
                              _quantityController.text = _quantity.toString();
                            }
                          });
                          _calculateNutritionalValues();
                        },
                      ),
                      SizedBox(
                        width: 40,
                        height: 50,
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (value) {
                            if (value.isNotEmpty && _totalCarbohydrate != 0) {
                              setState(() {
                                _quantity = int.parse(value);
                              });
                              _calculateNutritionalValues();
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            _quantity++;
                            _quantityController.text = _quantity.toString();
                          });
                          _calculateNutritionalValues();
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
          child: SizedBox(height: 40, child: _buildDropdownButton()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedType != null &&
                (widget.receipt != null || widget.barcode != null) &&
                _quantity != 0) {
              _addOrUpdateFoodList();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Listeye eklendi!'),
                  duration: Duration(seconds: 1),
                ),
              );
              Navigator.of(context).pop();
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
  }

  Widget _buildDropdownButton() {
    var nutritionalValuesList = widget.receiptOrBarcodes == FoodType.RECEIPT
        ? widget.receipt?.nutritionalValuesList ?? []
        : widget.barcode?.nutritionalValuesList ?? [];

    return DropdownButton<String>(
      alignment: Alignment.center,
      value: _selectedType,
      onChanged: (newValue) {
        setState(() {
          _selectedType = newValue;
        });
        _calculateNutritionalValues();
      },
      items: nutritionalValuesList.map((item) {
        return DropdownMenuItem<String>(
          alignment: Alignment.center,
          value: item.type,
          child: Text(item.type ?? ""),
        );
      }).toList(),
    );
  }
}
