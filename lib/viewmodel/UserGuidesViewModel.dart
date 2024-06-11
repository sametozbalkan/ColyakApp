import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:colyakapp/service/HttpBuild.dart';
import 'package:colyakapp/model/PDFJson.dart';

class UserGuidesViewModel extends ChangeNotifier {
  bool isLoading = false;
  List<PDFJson> pdflistesi = [];

  UserGuidesViewModel() {
    initializeData();
  }

  Future<void> initializeData() async {
    setLoading(true);
    await fetchPDFs();
    setLoading(false);
  }

  Future<void> fetchPDFs() async {
    try {
      final response = await HttpBuildService.sendRequest('GET', "api/image/get/pdfListData2", token: true);

      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      pdflistesi = data.map((json) => PDFJson.fromJson(json)).toList();
    } catch (e) {
      print('Failed to load pdf: $e');
    }
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
