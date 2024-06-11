import 'dart:convert';

import 'package:colyakapp/model/BolusJson.dart';
import 'package:colyakapp/service/HttpBuild.dart';
import 'package:flutter/material.dart';
import 'package:colyakapp/model/BarcodeJson.dart';
import 'package:colyakapp/model/ReceiptJson.dart';

class AddMealViewModel extends ChangeNotifier {
  List<ReceiptJson> receiptsMeal = [];
  List<BarcodeJson> barcodesMeal = [];
  List<ReceiptJson> filteredReceipts = [];
  List<BarcodeJson> filteredBarcodes = [];
  List<FoodListComplex> foodListComplex = [];

  AddMealViewModel() {
    filteredReceipts = receiptsMeal;
    filteredBarcodes = barcodesMeal;
  }

  Future<void> initializeData() async {
    await Future.wait([_fetchReceipts(), _fetchBarcodes()]);
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

  Future<void> _fetchReceipts() async {
    var response = await HttpBuildService.sendRequest(
        "GET", "api/receipts/getAll/all",
        token: true);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    receiptsMeal = data.map((json) => ReceiptJson.fromJson(json)).toList();
    filteredReceipts = receiptsMeal;
    notifyListeners();
  }

  Future<void> _fetchBarcodes() async {
    var response = await HttpBuildService.sendRequest("GET", "api/barcodes/all",
        token: true);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    barcodesMeal = data.map((json) => BarcodeJson.fromJson(json)).toList();
    filteredBarcodes = barcodesMeal;
    notifyListeners();
  }
}
