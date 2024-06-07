import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colyakapp/AddMealScreen.dart';
import 'package:colyakapp/BarcodeJson.dart';
import 'package:flutter/material.dart';
import 'HttpBuild.dart';
import 'ReceiptDetailScreen.dart';
import 'ReceiptJson.dart';
import 'CacheManager.dart';
import 'Shimmer.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  List<ReceiptJson> receipts = [];
  List<ReceiptJson> favorites = [];
  List<ReceiptJson> filteredReceipts = [];
  List<ReceiptJson> filteredFavorites = [];
  Map<String, Uint8List?> imageBytesMap = {};
  Set<String> loadedImages = {};
  ScrollController receiptsController = ScrollController();
  ScrollController favoritesController = ScrollController();
  int loadedItemCount = 8;
  int loadedFavoritesItemCount = 8;

  @override
  void initState() {
    super.initState();
    initializeData();
    receiptsController.addListener(
        () => _onScroll(receiptsController, filteredReceipts, loadedItemCount));
    favoritesController.addListener(() => _onScroll(
        favoritesController, filteredFavorites, loadedFavoritesItemCount));
  }

  @override
  void dispose() {
    receiptsController.dispose();
    favoritesController.dispose();
    super.dispose();
  }

  Future<void> initializeData() async {
    await Future.wait([_fetchReceipts(), _fetchFavorites(), _fetchBarcodes()]);
    _loadCachedImages();
    _loadImagesInBackground(filteredReceipts, loadedItemCount);
    _loadImagesInBackground(filteredFavorites, loadedFavoritesItemCount);
  }

  Future<void> _fetchReceipts() async {
    var response = await HttpBuildService.sendRequest(
        "GET", "api/receipts/getAll/all",
        token: true);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    setState(() {
      receipts = data.map((json) => ReceiptJson.fromJson(json)).toList();
      filteredReceipts = receipts;
      receiptsMeal = receipts;
    });
  }

  Future<void> _fetchFavorites() async {
    var response = await HttpBuildService.sendRequest(
        "GET", "api/likes/favoriteList",
        token: true);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    setState(() {
      favorites = data.map((json) => ReceiptJson.fromJson(json)).toList();
      filteredFavorites = favorites;
    });
  }

  Future<void> _fetchBarcodes() async {
    var response = await HttpBuildService.sendRequest("GET", "api/barcodes/all",
        token: true);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    setState(() {
      barcodesMeal = data.map((json) => BarcodeJson.fromJson(json)).toList();
    });
  }

  Future<void> _onScroll(ScrollController controller,
      List<ReceiptJson> receipts, int itemCount) async {
    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 200) {
      setState(() {
        itemCount += 8;
      });
      await _loadImagesInBackground(receipts, itemCount);
    }
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
  }

  Future<void> _fetchImage(String imageUrl) async {
    Uint8List? imageBytes = await CacheManager().getImageBytes(imageUrl);
    if (imageBytes != null) {
      setState(() {
        imageBytesMap[imageUrl] = imageBytes;
        loadedImages.add(imageUrl);
      });
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
  }

  void _filterReceipts(String query) {
    setState(() {
      filteredReceipts = receipts.where((receipt) {
        return receipt.receiptName!.toLowerCase().contains(query.toLowerCase());
      }).toList();
      filteredFavorites = favorites.where((receipt) {
        return receipt.receiptName!.toLowerCase().contains(query.toLowerCase());
      }).toList();
      loadedItemCount = 8;
      loadedFavoritesItemCount = 8;
    });
    _loadImagesInBackground(filteredReceipts, loadedItemCount);
    _loadImagesInBackground(filteredFavorites, loadedFavoritesItemCount);
  }

  Future<void> toggleLike(int receiptId, bool isLiked) async {
    String path = isLiked ? "api/likes/unlike" : "api/likes/like";
    try {
      final response = await HttpBuildService.sendRequest('POST', path,
          body: {'receiptId': receiptId}, token: true);
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isLiked = !isLiked;
          if (isLiked) {
            final receipt = receipts.firstWhere((r) => r.id == receiptId);
            favorites.add(receipt);
          } else {
            favorites.removeWhere((r) => r.id == receiptId);
          }
          filteredFavorites = favorites;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              isLiked ? 'Favorilere eklendi!' : 'Favorilerden kaldırıldı!'),
          duration: const Duration(seconds: 1),
        ));
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Widget _buildGridView(
      List<ReceiptJson> receipts, ScrollController controller) {
    return GridView.builder(
      controller: controller,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.91),
      itemCount: receipts.length,
      itemBuilder: (context, index) {
        return _buildReceiptCard(receipts[index]);
      },
    );
  }

  Widget _buildEmptyFavorites() {
    return const Center(
      child: Text(
        'Favoriler Boş',
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _buildReceiptCard(ReceiptJson receipt) {
    String imageUrl =
        "https://api.colyakdiyabet.com.tr/api/image/get/${receipt.imageId}";
    bool isLiked = favorites.any((favorite) => favorite.id == receipt.id);
    return GestureDetector(
      onTap: () async {
        if (imageBytesMap.containsKey(imageUrl)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptDetailScreen(
                  receipt: receipt, imageUrl: imageUrl, isLiked: isLiked),
            ),
          ).then((value) {
            if (value != null) {
              setState(() {
                isLiked = value;
                if (isLiked) {
                  favorites.add(receipt);
                } else {
                  favorites.removeWhere((r) => r.id == receipt.id);
                }
                filteredFavorites = favorites;
              });
            }
          });
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 7,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8)),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (context, url) => Shimmer(
                          child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.grey.shade300)),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Positioned(
                    top: -1,
                    right: -1,
                    child: IconButton(
                      onPressed: () async {
                        await toggleLike(receipt.id!, isLiked);
                      },
                      icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(receipt.receiptName!,
                        softWrap: true,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarifler')),
      body: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: "Ara",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _filterReceipts(value);
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(color: Color(0xFFFFF1EC)),
              child: const TabBar(
                indicatorColor: Color(0xFFFF7A37),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black,
                tabs: [
                  Tab(text: 'Tarifler'),
                  Tab(text: 'Favorilerim'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  RefreshIndicator(
                    onRefresh: initializeData,
                    child: _buildGridView(filteredReceipts, receiptsController),
                  ),
                  RefreshIndicator(
                    onRefresh: initializeData,
                    child: filteredFavorites.isEmpty
                        ? _buildEmptyFavorites()
                        : _buildGridView(
                            filteredFavorites, favoritesController),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
