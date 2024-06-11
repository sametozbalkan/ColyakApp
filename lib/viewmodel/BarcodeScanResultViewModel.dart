import 'package:colyakapp/model/BarcodeJson.dart';
import 'package:flutter/material.dart';

class BarcodeScanResultViewModel extends ChangeNotifier {
  final BarcodeJson barcode;
  late String imageUrl;

  BarcodeScanResultViewModel({required this.barcode}) {
    imageUrl =
        "https://api.colyakdiyabet.com.tr/api/image/get/${barcode.imageId}";
    notifyListeners();
  }
}
