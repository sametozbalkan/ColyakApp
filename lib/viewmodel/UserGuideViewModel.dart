import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserGuideViewModel extends ChangeNotifier {
  final int id;
  final String name;
  bool isLoading = true;
  Uint8List? pdfData;
  String? errorMessage;

  UserGuideViewModel(this.id, this.name) {
    _fetchPdfData();
  }

  Future<void> _fetchPdfData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.colyakdiyabet.com.tr/api/image/get/$id'));
      if (response.statusCode == 200) {
        pdfData = response.bodyBytes;
      } else {
        errorMessage = 'Failed to load PDF';
      }
    } catch (e) {
      errorMessage = 'Failed to load PDF: $e';
    }
    isLoading = false;
    notifyListeners();
  }
}
