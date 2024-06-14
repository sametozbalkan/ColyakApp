import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:colyakapp/service/HttpBuild.dart';
import 'package:colyakapp/cachemanager/CacheManager.dart';
import 'package:colyakapp/model/ReceiptJson.dart';

class ReceiptPageViewModel extends ChangeNotifier {
  List<ReceiptJson> receipts = [];
  List<ReceiptJson> favorites = [];
  List<ReceiptJson> filteredReceipts = [];
  List<ReceiptJson> filteredFavorites = [];
  Map<String, Uint8List?> imageBytesMap = {};
  Set<String> loadedImages = {};
  int loadedItemCount = 8;
  int loadedFavoritesItemCount = 8;

  Future<void> initializeData() async {
    await Future.wait([_fetchReceipts(), _fetchFavorites()]);
    _loadCachedImages();
    _loadImagesInBackground(filteredReceipts, loadedItemCount);
    _loadImagesInBackground(filteredFavorites, loadedFavoritesItemCount);
  }

  Future<void> _fetchReceipts() async {
    var response = await HttpBuildService.sendRequest(
        "GET", "api/receipts/getAll/all",
        token: true);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    receipts = data.map((json) => ReceiptJson.fromJson(json)).toList();
    filteredReceipts = receipts;
    notifyListeners();
  }

  Future<void> _fetchFavorites() async {
    var response = await HttpBuildService.sendRequest(
        "GET", "api/likes/favoriteList",
        token: true);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    favorites = data.map((json) => ReceiptJson.fromJson(json)).toList();
    filteredFavorites = favorites;
    notifyListeners();
  }

  Future<void> _loadCachedImages() async {
    for (ReceiptJson receipt in filteredReceipts + filteredFavorites) {
      String imageUrl =
          "https://api.colyakdiyabet.com.tr/api/image/get/${receipt.imageId}";
      Uint8List? imageBytes = await CacheManager().getImageBytes(imageUrl);
      if (imageBytes != null) {
        imageBytesMap[imageUrl] = imageBytes;
        loadedImages.add(imageUrl);
      }
    }
    notifyListeners();
  }

  Future<void> _fetchImage(String imageUrl) async {
    Uint8List? imageBytes = await CacheManager().getImageBytes(imageUrl);
    if (imageBytes != null) {
      imageBytesMap[imageUrl] = imageBytes;
      loadedImages.add(imageUrl);
      notifyListeners();
    }
  }

  Future<void> _loadImagesInBackground(
      List<ReceiptJson> receipts, int itemCount) async {
    await Future.delayed(const Duration(milliseconds: 100), () async {
      for (int i = 0; i < itemCount && i < receipts.length; i++) {
        String imageUrl =
            "https://api.colyakdiyabet.com.tr/api/image/get/${receipts[i].imageId}";
        if (!loadedImages.contains(imageUrl)) {
          await _fetchImage(imageUrl);
        }
      }
    });
    notifyListeners();
  }

  void filterReceipts(String query) {
    filteredReceipts = receipts.where((receipt) {
      return receipt.receiptName!.toLowerCase().contains(query.toLowerCase());
    }).toList();
    filteredFavorites = favorites.where((receipt) {
      return receipt.receiptName!.toLowerCase().contains(query.toLowerCase());
    }).toList();
    loadedItemCount = 8;
    loadedFavoritesItemCount = 8;
    _loadImagesInBackground(filteredReceipts, loadedItemCount);
    _loadImagesInBackground(filteredFavorites, loadedFavoritesItemCount);
    notifyListeners();
  }

  Future<void> toggleLike(int receiptId, bool isLiked) async {
    String path = isLiked ? "api/likes/unlike" : "api/likes/like";
    try {
      final response = await HttpBuildService.sendRequest('POST', path,
          body: {'receiptId': receiptId}, token: true);
      if (response.statusCode == 200 || response.statusCode == 201) {
        isLiked = !isLiked;
        if (isLiked) {
          final receipt = receipts.firstWhere((r) => r.id == receiptId);
          favorites.add(receipt);
        } else {
          favorites.removeWhere((r) => r.id == receiptId);
        }
        filteredFavorites = favorites;
        notifyListeners();
      } else {
        debugPrint(response.statusCode.toString());
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  void updateLikeStatus(ReceiptJson receipt, bool isLiked) {
    if (isLiked) {
      favorites.add(receipt);
    } else {
      favorites.removeWhere((r) => r.id == receipt.id);
    }
    filteredFavorites = favorites;
    notifyListeners();
  }
}
