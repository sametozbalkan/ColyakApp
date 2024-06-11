import 'package:colyakapp/model/BolusJson.dart';
import 'package:flutter/material.dart';

class MealViewModel extends ChangeNotifier {
  List<FoodListComplex> foodListComplex = [];
  double totalCarb = 0;

  void addItemsToFoodList(List<FoodListComplex> items) {
    foodListComplex.addAll(items);
    updateTotalCarb();
  }

  void updateTotalCarb() {
    totalCarb =
        foodListComplex.fold(0, (sum, item) => sum + (item.carbonhydrate ?? 0));
    notifyListeners();
  }

  void removeFood(FoodListComplex food) {
    foodListComplex.remove(food);
    updateTotalCarb();
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
        updateTotalCarb();
      } else {
        removeFood(food);
      }
    }
  }
}
