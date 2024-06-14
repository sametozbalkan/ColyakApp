import 'package:flutter/material.dart';
import 'package:colyakapp/model/BolusJson.dart';

class MealViewModel extends ChangeNotifier {
  List<FoodListComplex> foodListComplex = [];
  List<FoodList> bolusFoodList = [];
  double totalCarb = 0;

  void initializeData(List<FoodListComplex> foodlist) {
    foodListComplex = foodlist;
    updateTotalCarbAndBolusFoodList();
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
    bolusFoodList.clear();
    for (var food in foodListComplex) {
      bolusFoodList.add(FoodList(
        foodType: food.foodType,
        foodId: food.foodId,
        carbonhydrate: food.carbonhydrate,
      ));
    }
  }

  void removeFood(FoodListComplex food) {
    foodListComplex.remove(food);
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
}
