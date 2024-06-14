import 'package:colyakapp/model/BolusJson.dart';
import 'package:flutter/material.dart';
import 'package:colyakapp/model/BarcodeJson.dart';
import 'package:colyakapp/model/ReceiptJson.dart';

class AddMealViewModel extends ChangeNotifier {
  List<ReceiptJson> receiptsMeal = [];
  List<BarcodeJson> barcodesMeal = [];
  List<ReceiptJson> filteredReceipts = [];
  List<BarcodeJson> filteredBarcodes = [];
  List<FoodListComplex> foodListComplex = [];

  Future<void> initializeData(
      List<ReceiptJson> receiptList, List<BarcodeJson> barcodeList) async {
    filteredReceipts = receiptList;
    filteredBarcodes = barcodeList;
  }

  void search(String value) {
    final query = value.toLowerCase();
    filteredReceipts = receiptsMeal
        .where((receipt) =>
            receipt.receiptName?.toLowerCase().contains(query) ?? false)
        .toList();
    filteredBarcodes = barcodesMeal
        .where(
            (barcode) => barcode.name?.toLowerCase().contains(query) ?? false)
        .toList();
    notifyListeners();
  }

  void updateReceipts(List<ReceiptJson> newReceipts) {
    receiptsMeal = newReceipts;
    search('');
    notifyListeners();
  }

  void updateBarcodes(List<BarcodeJson> newBarcodes) {
    barcodesMeal = newBarcodes;
    search('');
    notifyListeners();
  }
}
