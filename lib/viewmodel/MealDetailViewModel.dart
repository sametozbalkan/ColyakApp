import 'package:colyakapp/model/BolusJson.dart';
import 'package:flutter/material.dart';
import 'package:colyakapp/model/BarcodeJson.dart';
import 'package:colyakapp/model/FoodType.dart';
import 'package:colyakapp/model/ReceiptJson.dart';

class MealDetailViewModel extends ChangeNotifier {
  final FoodType receiptOrBarcodes;
  final ReceiptJson? receipt;
  final BarcodeJson? barcode;

  List<FoodListComplex> foodListComplex = [];
  List<FoodList> bolusFoodList = [];
  int quantity = 1;
  String? selectedType;
  double totalCarbohydrate = 0;
  double totalCalories = 0;
  double totalProtein = 0;
  double totalFat = 0;
  final TextEditingController quantityController =
      TextEditingController(text: "1");

  MealDetailViewModel({
    required this.receiptOrBarcodes,
    this.receipt,
    this.barcode,
  }) {
    selectedType = receiptOrBarcodes == FoodType.RECEIPT
        ? receipt?.nutritionalValuesList?.first.type
        : barcode?.nutritionalValuesList?.first.type;
    _calculateNutritionalValues();
  }

  void _calculateNutritionalValues() {
    double totalCarb = 0;
    double totalCal = 0;
    double totalProt = 0;
    double totalFats = 0;

    var nutritionalValuesList = receiptOrBarcodes == FoodType.RECEIPT
        ? receipt?.nutritionalValuesList ?? []
        : barcode?.nutritionalValuesList ?? [];

    for (var item in nutritionalValuesList) {
      if (item.type == selectedType) {
        totalCarb += item.carbohydrateAmount ?? 0;
        totalCal += item.calorieAmount ?? 0;
        totalProt += item.proteinAmount ?? 0;
        totalFats += item.fatAmount ?? 0;
      }
    }

    totalCarbohydrate = totalCarb * quantity;
    totalCalories = totalCal * quantity;
    totalProtein = totalProt * quantity;
    totalFat = totalFats * quantity;

    notifyListeners();
  }

  void setQuantity(int newQuantity) {
    quantity = newQuantity;
    quantityController.text = newQuantity.toString();
    _calculateNutritionalValues();
  }

  void setSelectedType(String? newType) {
    selectedType = newType;
    _calculateNutritionalValues();
  }

  void addOrUpdateFoodList() {
    var foodId = barcode?.id ?? receipt?.id;
    var foodName = barcode?.name ?? receipt?.receiptName;

    if (foodId == null || foodName == null || selectedType == null) {
      return;
    }

    var existingItemIndex = foodListComplex.indexWhere(
      (element) => element.foodId == foodId && element.type == selectedType,
    );

    if (existingItemIndex != -1) {
      foodListComplex[existingItemIndex].amount =
          (foodListComplex[existingItemIndex].amount ?? 0) + quantity;
      foodListComplex[existingItemIndex].carbonhydrate =
          (foodListComplex[existingItemIndex].carbonhydrate ?? 0) +
              totalCarbohydrate;

      var existingBolusItemIndex = bolusFoodList.indexWhere(
        (element) => element.foodId == foodId,
      );
      if (existingBolusItemIndex != -1) {
        bolusFoodList[existingBolusItemIndex].carbonhydrate =
            (bolusFoodList[existingBolusItemIndex].carbonhydrate ?? 0) +
                totalCarbohydrate;
      }
    } else {
      FoodListComplex _foodListComplex = FoodListComplex(
        carbonhydrate: totalCarbohydrate,
        foodId: foodId,
        foodName: foodName,
        foodType: receiptOrBarcodes.name,
        type: selectedType,
        amount: quantity,
      );

      FoodList newItem = FoodList(
        foodType: receiptOrBarcodes.name,
        foodId: foodId,
        carbonhydrate: totalCarbohydrate,
      );

      foodListComplex.add(_foodListComplex);
      bolusFoodList.add(newItem);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }
}
