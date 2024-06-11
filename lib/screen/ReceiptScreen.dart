import 'package:colyakapp/model/ReceiptJson.dart';
import 'package:colyakapp/viewmodel/ReceiptPageViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colyakapp/screen/ReceiptDetailScreen.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReceiptPageViewModel()..initializeData(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Tarifler')),
        body: Consumer<ReceiptPageViewModel>(
          builder: (context, viewModel, child) {
            return DefaultTabController(
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
                        viewModel.filterReceipts(value);
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
                          onRefresh: viewModel.initializeData,
                          child: _buildGridView(viewModel.filteredReceipts,
                              viewModel, viewModel.loadedItemCount, context),
                        ),
                        RefreshIndicator(
                          onRefresh: viewModel.initializeData,
                          child: viewModel.filteredFavorites.isEmpty
                              ? _buildEmptyFavorites()
                              : _buildGridView(
                                  viewModel.filteredFavorites,
                                  viewModel,
                                  viewModel.loadedFavoritesItemCount,
                                  context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridView(List<ReceiptJson> receipts,
      ReceiptPageViewModel viewModel, int itemCount, BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.91),
      itemCount: receipts.length,
      itemBuilder: (context, index) {
        return _buildReceiptCard(receipts[index], viewModel, context);
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

  Widget _buildReceiptCard(ReceiptJson receipt, ReceiptPageViewModel viewModel,
      BuildContext context) {
    String imageUrl =
        "https://api.colyakdiyabet.com.tr/api/image/get/${receipt.imageId}";
    bool isLiked =
        viewModel.favorites.any((favorite) => favorite.id == receipt.id);
    return GestureDetector(
      onTap: () async {
        if (viewModel.imageBytesMap.containsKey(imageUrl)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptDetailScreen(
                  receipt: receipt, imageUrl: imageUrl, isLiked: isLiked),
            ),
          ).then((value) {
            if (value != null && value != isLiked) {
              viewModel.updateLikeStatus(receipt, value);
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
                      placeholder: (context, url) => Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey.shade300),
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
                        await viewModel.toggleLike(receipt.id!, isLiked);
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
}
