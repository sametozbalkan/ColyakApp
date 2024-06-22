import 'package:colyakapp/model/BolusJson.dart';
import 'package:flutter/foundation.dart';

class BolusFoodListViewModel with ChangeNotifier {
  double _totalCarb = 0;
  List<FoodListComplex> _foodList = [];

  double get totalCarb => _totalCarb;
  List<FoodListComplex> get foodList => _foodList;

  void updateTotalCarb(double totalCarb) {
    _totalCarb = totalCarb;
    notifyListeners();
  }

  void updateFoodList(List<FoodListComplex> foodList) {
    _foodList = foodList;
    notifyListeners();
  }

  void reset() {
    _totalCarb = 0;
    _foodList = [];
    notifyListeners();
  }
}
