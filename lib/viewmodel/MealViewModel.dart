import 'package:flutter/material.dart';
import 'package:colyakapp/model/BolusJson.dart';

class MealViewModel extends ChangeNotifier {
  List<FoodListComplex> foodListComplex = [];
  List<FoodList> bolusFoodList = [];
  bool hasManualCarbEntry = false;
  double totalCarb = 0;
  List<FoodListComplex> get foodList => foodListComplex;

  void initializeData(List<FoodListComplex> foodlist) {
    foodListComplex = foodlist;
    updateTotalCarbAndBolusFoodList();
  }

  void reset() {
    totalCarb = 0;
    foodListComplex = [];
    bolusFoodList = [];
    hasManualCarbEntry = false;
    notifyListeners();
  }

  void addItemsToFoodList(List<FoodListComplex> items) {
    foodListComplex.addAll(items);
    updateTotalCarbAndBolusFoodList();
  }

  void updateTotalCarbAndBolusFoodList() {
    totalCarb =
        foodListComplex.fold(0, (sum, item) => sum + (item.carbonhydrate ?? 0));
    updateBolusFoodList();
    notifyListeners();
  }

  void updateBolusFoodList() {
    bolusFoodList = foodListComplex.map((food) {
      return FoodList(
        foodType: food.foodType,
        foodId: food.foodId,
        carbonhydrate: food.carbonhydrate,
      );
    }).toList();
  }

  void removeFood(FoodListComplex food) {
    foodListComplex.remove(food);
    if (food.foodName == 'Ekstra Karbonhidrat') {
      hasManualCarbEntry = false;
    }
    updateTotalCarbAndBolusFoodList();
  }

  void updateCarb(FoodListComplex food, int delta) {
    int index = foodListComplex.indexOf(food);
    if (index != -1) {
      final updatedAmount = (food.amount ?? 0) + delta;
      if (updatedAmount > 0) {
        double originalCarbPerUnit =
            (food.carbonhydrate ?? 0) / (food.amount ?? 1);
        food.amount = updatedAmount;
        food.carbonhydrate = originalCarbPerUnit * updatedAmount;
        updateTotalCarbAndBolusFoodList();
      } else {
        removeFood(food);
      }
    }
  }

  void addManualCarb(double newCarb) {
    FoodListComplex manualCarb = FoodListComplex(
        foodType: "BARCODE",
        foodId: 248,
        foodName: 'Ekstra Karbonhidrat',
        carbonhydrate: newCarb,
        amount: 1,
        type: 'Ekstra');
    foodListComplex.add(manualCarb);
    hasManualCarbEntry = true;
    updateTotalCarbAndBolusFoodList();
  }
}
