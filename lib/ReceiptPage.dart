import 'dart:convert';
import 'dart:typed_data';
import 'package:colyakapp/AddMealScreen.dart';
import 'package:colyakapp/BarcodeJson.dart';
import 'package:colyakapp/ReceiptJson.dart';
import 'package:colyakapp/Shimmer.dart';
import 'package:flutter/material.dart';
import 'ReceiptDetailScreen.dart';
import 'HttpBuild.dart';
import 'package:http/http.dart' as http;

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  List<ReceiptJson> favoriler = [];
  List<ReceiptJson> receipts = [];
  Map<String, Uint8List?> imageBytesMap = {};
  List<ReceiptJson> filteredReceipts = [];
  List<ReceiptJson> filteredFavorites = [];
  ScrollController scrollController = ScrollController();
  ScrollController favoritesScrollController = ScrollController();
  int _loadedItemCount = 8;
  int _loadedFavoritesItemCount = 8;

  @override
  void initState() {
    super.initState();
    initializeData();
    scrollController.addListener(_onScroll);
    favoritesScrollController.addListener(_onFavoritesScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    favoritesScrollController.dispose();
    super.dispose();
  }

  Future<void> initializeData() async {
    try {
      await Future.wait([
        _fetchReceipts(),
        _barkodlariAl(),
        _fetchFavorites(),
      ]);
      await _loadImageBytes(filteredReceipts, _loadedItemCount);
      await _loadImageBytes(filteredFavorites, _loadedFavoritesItemCount);
    } catch (e) {
      print("Critical error posting refresh token: $e");
    }
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      setState(() {
        _loadedItemCount += 8;
      });
      _loadImageBytes(filteredReceipts, _loadedItemCount);
    }
  }

  void _onFavoritesScroll() {
    if (favoritesScrollController.position.pixels >=
        favoritesScrollController.position.maxScrollExtent - 200) {
      setState(() {
        _loadedFavoritesItemCount += 8;
      });
      _loadImageBytes(filteredFavorites, _loadedFavoritesItemCount);
    }
  }

  Future<void> _barkodlariAl() async {
    var response = await HttpBuildService.sendRequest("GET", "api/barcodes/all",
        token: true);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    if (mounted) {
      setState(() {
        barcodesMeal = data.map((json) => BarcodeJson.fromJson(json)).toList();
      });
    }
  }

  Future<void> _fetchReceipts() async {
    var response = await HttpBuildService.sendRequest(
        "GET", "api/receipts/getAll/all",
        token: true);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    if (mounted) {
      setState(() {
        receipts = data.map((json) => ReceiptJson.fromJson(json)).toList();
        receiptsMeal = receipts;
        filteredReceipts = receipts;
      });
    }
  }

  Future<void> _fetchFavorites() async {
    var response = await HttpBuildService.sendRequest(
        "GET", "api/likes/favoriteList",
        token: true);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    if (mounted) {
      setState(() {
        favoriler = data.map((json) => ReceiptJson.fromJson(json)).toList();
        filteredFavorites = favoriler;
      });
    }
  }

  Future<void> _loadImageBytes(
      List<ReceiptJson> receipts, int itemCount) async {
    List<Future<void>> futures = [];
    for (int i = 0; i < itemCount && i < receipts.length; i++) {
      ReceiptJson receipt = receipts[i];
      int imageId = receipt.imageId ?? 0;
      String imageUrl =
          "https://api.colyakdiyabet.com.tr/api/image/get/$imageId";

      if (!imageBytesMap.containsKey(imageUrl) ||
          imageBytesMap[imageUrl] == null) {
        futures.add(_fetchImage(imageUrl));
      }
    }
    await Future.wait(futures);
  }

  Future<void> _fetchImage(String imageUrl) async {
    try {
      var response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            imageBytesMap[imageUrl] = response.bodyBytes;
          });
        }
      } else {
        print('Failed to fetch image. Error code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch image. Error: $e');
    }
  }

  Future<void> _refreshData() async {
    await initializeData();
  }

  TextEditingController searchController = TextEditingController();

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
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: "Ara",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _filterReceipts(value);
                  });
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
                    onRefresh: _refreshData,
                    child: _buildGridView(filteredReceipts, scrollController),
                  ),
                  RefreshIndicator(
                    onRefresh: _refreshData,
                    child: _buildGridView(
                        filteredFavorites, favoritesScrollController),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _filterReceipts(String query) {
    filteredReceipts = receipts.where((receipt) {
      return receipt.receiptName!.toLowerCase().contains(query.toLowerCase());
    }).toList();
    filteredFavorites = favoriler.where((receipt) {
      return receipt.receiptName!.toLowerCase().contains(query.toLowerCase());
    }).toList();
    _loadedItemCount = 8;
    _loadedFavoritesItemCount = 8;
    _loadImageBytes(filteredReceipts, _loadedItemCount);
    _loadImageBytes(filteredFavorites, _loadedFavoritesItemCount);
  }

  Future<void> toggleLike(int receiptId, String path, bool isLiked) async {
    try {
      final Map<String, dynamic> likeDetails = {
        'receiptId': receiptId,
      };

      final response = await HttpBuildService.sendRequest('POST', path,
          body: likeDetails, token: true);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isLiked = !isLiked;
        });
        await _fetchFavorites();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                isLiked ? 'Favorilere eklendi!' : 'Favorilerden kaldırıldı!'),
            duration: const Duration(seconds: 1),
          ),
        );
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
      itemCount: receipts.length < _loadedItemCount
          ? receipts.length
          : _loadedItemCount,
      itemBuilder: (context, index) {
        return _buildReceiptCard(receipts[index]);
      },
    );
  }

  Widget _buildReceiptCard(ReceiptJson receipt) {
    String imageUrl =
        "https://api.colyakdiyabet.com.tr/api/image/get/${receipt.imageId}";
    bool isLiked = favoriler.any((favorite) => favorite.id == receipt.id);
    return GestureDetector(
      onTap: () {
        if (imageBytesMap.containsKey(imageUrl)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptDetailScreen(
                receipt: receipt,
                imageBytes: imageBytesMap[imageUrl]!,
              ),
            ),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
                      topRight: Radius.circular(8),
                    ),
                    child: imageBytesMap.containsKey(imageUrl)
                        ? Image.memory(
                            imageBytesMap[imageUrl]!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.fitWidth,
                          )
                        : Shimmer(
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.grey.shade300,
                            ),
                          ),
                  ),
                  Positioned(
                    top: -1,
                    right: -1,
                    child: IconButton(
                      onPressed: () async {
                        isLiked
                            ? await toggleLike(
                                receipt.id!, "api/likes/unlike", isLiked)
                            : await toggleLike(
                                receipt.id!, "api/likes/like", isLiked);
                      },
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                      ),
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
}
