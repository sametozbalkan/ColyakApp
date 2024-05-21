import 'dart:convert';
import 'dart:typed_data';
import 'package:colyakapp/AddMealScreen.dart';
import 'package:colyakapp/ReceiptReadyFoodsJson.dart';
import 'package:flutter/material.dart';
import 'ReceiptDetailScreen.dart';
import 'HttpBuild.dart';
import 'package:http/http.dart' as http;

List<ReceiptJson> favoriler = [];

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  List<ReceiptJson> receipts = [];
  Map<String, Uint8List?> imageBytesMap = {};
  List<ReceiptJson> filteredReceipts = [];
  List<ReceiptJson> filteredFavorites = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    setState(() {
      isLoading = true;
    });
    try {
      await _fetchReceipts();
      await _hazirYiyecekleriAl();
      await _fetchFavorites();
      await _loadImageBytes();
    } catch (e) {
      print("Critical error posting refresh token: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _hazirYiyecekleriAl() async {
    var response = await sendRequest("GET", "api/ready-foods/getall",
        token: globaltoken, context: context);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    if (mounted) {
      setState(() {
        readyfoodsMeal =
            data.map((json) => ReadyFoodsJson.fromJson(json)).toList();
      });
    }
  }

  Future<void> _fetchReceipts() async {
    var response = await sendRequest("GET", "api/receipts/getAll/all",
        token: globaltoken, context: context);
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
    var response = await sendRequest("GET", "api/likes/favoriteList",
        token: globaltoken, context: context);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    if (mounted) {
      setState(() {
        favoriler = data.map((json) => ReceiptJson.fromJson(json)).toList();
        filteredFavorites = favoriler;
      });
    }
  }

  Future<void> _loadImageBytes() async {
    for (ReceiptJson receipt in filteredReceipts) {
      int imageId = receipt.imageId ?? 0;
      String imageUrl =
          "https://api.colyakdiyabet.com.tr/api/image/get/$imageId";
      if (!imageBytesMap.containsKey(imageUrl)) {
        var response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              imageBytesMap[imageUrl] = response.bodyBytes;
            });
          }
        } else {
          print('Resim alınamadı. Hata kodu: ${response.statusCode}');
        }
      }
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : DefaultTabController(
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
                          filteredReceipts = receipts.where((receipt) {
                            return receipt.receiptName!
                                .toLowerCase()
                                .contains(value.toLowerCase());
                          }).toList();
                          filteredFavorites = favoriler.where((receipt) {
                            return receipt.receiptName!
                                .toLowerCase()
                                .contains(value.toLowerCase());
                          }).toList();
                        });
                      },
                    ),
                  ),
                  const TabBar(
                    indicatorColor: Color(0xFFFF7A37),
                    labelColor: Color(0xFFFF7A37),
                    unselectedLabelColor: Colors.black,
                    tabs: [
                      Tab(text: 'Tarifler'),
                      Tab(text: 'Favorilerim'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: <Widget>[
                        RefreshIndicator(
                          onRefresh: _refreshData,
                          child: _buildGridView(filteredReceipts),
                        ),
                        RefreshIndicator(
                          onRefresh: _refreshData,
                          child: _buildGridView(filteredFavorites),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGridView(List<ReceiptJson> receipts) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.80),
      itemCount: receipts.length,
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptDetailScreen(
              receipt: receipt,
              imageBytes: imageBytesMap[imageUrl]!,
              isLiked: isLiked,
              updateFavorites: _fetchFavorites,
            ),
          ),
        );
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageBytesMap.containsKey(imageUrl))
              Expanded(
                flex: 6,
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: Image.memory(
                      imageBytesMap[imageUrl]!,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    receipt.receiptName!,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                      "${receipt.nutritionalValuesList != null && receipt.nutritionalValuesList!.isNotEmpty ? receipt.nutritionalValuesList![0].carbohydrateAmount?.toInt() ?? '' : ''}g karbonhidrat",
                      style: const TextStyle(fontSize: 13, color: Colors.black))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
