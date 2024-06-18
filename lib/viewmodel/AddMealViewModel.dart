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
    receiptsMeal = receiptList;
    barcodesMeal = barcodeList;
    filteredReceipts = receiptsMeal;
    filteredBarcodes = barcodesMeal;
    notifyListeners();
  }

  void search(String value) {
    filteredReceipts = receiptsMeal
        .where((receipt) => receipt.receiptName!.toLowerCase().contains(value.toLowerCase()))
        .toList();
    filteredBarcodes = barcodesMeal
        .where((barcode) => barcode.name!.toLowerCase().contains(value.toLowerCase()))
        .toList();
    notifyListeners();
  }
}
