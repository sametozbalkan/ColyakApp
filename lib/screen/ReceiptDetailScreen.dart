import 'package:colyakapp/screen/ReplyCommentScreen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:colyakapp/service/HttpBuild.dart';
import 'package:colyakapp/viewmodel/ReceiptDetailViewModel.dart';
import 'package:colyakapp/model/ReceiptJson.dart';

class ReceiptDetailScreen extends StatelessWidget {
  final ReceiptJson receipt;
  final String imageUrl;
  final bool isLiked;

  const ReceiptDetailScreen({
    super.key,
    required this.receipt,
    required this.imageUrl,
    required this.isLiked,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReceiptDetailViewModel()
        ..liked = isLiked
        ..initializeData(receipt.id!),
      child: Consumer<ReceiptDetailViewModel>(
        builder: (context, viewModel, child) {
          return WillPopScope(
            onWillPop: () async {
              Navigator.pop(context, viewModel.liked);
              return false;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(receipt.receiptName.toString()),
                actions: [
                  IconButton(
                    onPressed: () async {
                      await viewModel.toggleLike(
                          receipt.id!,
                          viewModel.liked
                              ? "api/likes/unlike"
                              : "api/likes/like");
                    },
                    icon: Icon(
                      viewModel.liked ? Icons.favorite : Icons.favorite_border,
                      color: viewModel.liked ? Colors.red : Colors.black,
                    ),
                  ),
                ],
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context, viewModel.liked);
                  },
                ),
              ),
              body: DefaultTabController(
                length: 3,
                initialIndex: 0,
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 4 / 3,
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            placeholder: (context, url) => Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.grey.shade300,
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        Positioned(
                            bottom: 5,
                            right: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              height: 45,
                              width: 45,
                              child: Stack(
                                children: [
                                  Center(
                                    child: IconButton(
                                      onPressed: () => _showCommentsModal(
                                          context, viewModel),
                                      icon: const Icon(Icons.comment_rounded,
                                          color: Colors.black, size: 28),
                                    ),
                                  ),
                                  if (viewModel.commentReply.isNotEmpty)
                                    Positioned(
                                      right: -1,
                                      top: -3,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          viewModel.commentReply.length
                                              .toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )),
                      ],
                    ),
                    Container(
                      decoration: const BoxDecoration(color: Color(0xFFFFF1EC)),
                      child: const TabBar(
                        indicatorColor: Color(0xFFFF7A37),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.black,
                        tabs: [
                          Tab(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Malzeme\nListesi",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Tab(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Tarif\nDetayları",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Tab(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Besin\nDeğerleri",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: <Widget>[
                          _buildMaterialList(receipt),
                          _buildRecipeDetails(receipt),
                          _buildNutritionalValues(receipt),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMaterialList(ReceiptJson receipt) {
    return ListView.builder(
      itemCount: receipt.receiptItems!.length,
      itemBuilder: (context, index) {
        var product = receipt.receiptItems![index];
        return ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text("${product.productName}"),
              ),
              Text(
                  "${product.unit! % 1 == 0 ? product.unit!.toInt().toString() : product.unit!.toStringAsFixed(1)} ${product.type}")
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecipeDetails(ReceiptJson receipt) {
    return ListView.builder(
      itemCount: receipt.receiptDetails!.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text("${index + 1}- ${receipt.receiptDetails![index]}"),
        );
      },
    );
  }

  Widget _buildNutritionalValues(ReceiptJson receipt) {
    return ListView.builder(
      itemCount: receipt.nutritionalValuesList?.length,
      itemBuilder: (context, index) {
        final nutritionalValue = receipt.nutritionalValuesList![index];
        return Card(
          child: ListTile(
            title: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: const Color(0xFFFFF1EC),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 4,
                          height: 30,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFF7A37),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15))),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            child: Text(
                              nutritionalValue.type ?? "",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Container(
                          width: 4,
                          height: 30,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFF7A37),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15))),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Kalori (kcal):"),
                    Text(nutritionalValue.calorieAmount.toString()),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Karbonhidrat (g):"),
                    Text(nutritionalValue.carbohydrateAmount.toString()),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Protein (g):"),
                    Text(nutritionalValue.proteinAmount.toString()),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Yağ (g):"),
                    Text(nutritionalValue.fatAmount.toString()),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCommentsModal(
      BuildContext context, ReceiptDetailViewModel viewModel) {
    viewModel.commentController.text = '';
    viewModel.isUpdate = false;
    viewModel.commentIdForUpdate = null;

    showModalBottomSheet(
      backgroundColor: Colors.white,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return ChangeNotifierProvider.value(
          value: viewModel,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 10,
              right: 10,
              top: 20,
            ),
            child: Consumer<ReceiptDetailViewModel>(
              builder: (context, viewModel, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Yorumlar', style: TextStyle(fontSize: 18)),
                    const Divider(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 2.1,
                      width: double.infinity,
                      child: RefreshIndicator(
                        onRefresh: () => viewModel.initializeData(receipt.id!),
                        child: viewModel.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : viewModel.commentReply.isEmpty
                                ? const Center(child: Text("Henüz Yorum Yok"))
                                : ListView.builder(
                                    itemCount: viewModel.commentReply.length,
                                    itemBuilder: (context, index) {
                                      final commentResponse = viewModel
                                          .commentReply[index].commentResponse;
                                      final replyResponses = viewModel
                                          .commentReply[index].replyResponses;
                                      final replyCount =
                                          replyResponses?.length ?? 0;

                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ReplyCommentScreen(
                                                      replies: viewModel
                                                          .commentReply[index]
                                                          .replyResponses!,
                                                      commentId: commentResponse
                                                          .commentId!,
                                                      comment: commentResponse
                                                              .comment ??
                                                          "null",
                                                      commentUser:
                                                          commentResponse
                                                              .userName!,
                                                      createdTime:
                                                          commentResponse
                                                              .createdDate!),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          child: ListTile(
                                            title: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        commentResponse!
                                                            .userName
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      viewModel.timeSince(
                                                          DateTime.parse(
                                                              commentResponse
                                                                  .createdDate!)),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        commentResponse.comment
                                                            .toString(),
                                                        softWrap: true,
                                                      ),
                                                    ),
                                                    commentResponse.userName ==
                                                            HttpBuildService
                                                                .userName
                                                        ? PopupMenuButton<
                                                            String>(
                                                            color: Colors.white,
                                                            icon: const Icon(
                                                                Icons
                                                                    .more_vert),
                                                            onSelected: (String
                                                                result) async {
                                                              if (result ==
                                                                  'delete') {
                                                                await _confirmDeleteComment(
                                                                  context,
                                                                  viewModel,
                                                                  commentResponse
                                                                      .commentId!,
                                                                  "api/comments/",
                                                                  receipt.id!,
                                                                );
                                                              } else if (result ==
                                                                  'update') {
                                                                viewModel
                                                                        .commentController
                                                                        .text =
                                                                    commentResponse
                                                                        .comment!;
                                                                viewModel
                                                                        .isUpdate =
                                                                    true;
                                                                viewModel
                                                                        .commentIdForUpdate =
                                                                    commentResponse
                                                                        .commentId!;
                                                              }
                                                            },
                                                            itemBuilder: (BuildContext
                                                                    context) =>
                                                                <PopupMenuEntry<
                                                                    String>>[
                                                              const PopupMenuItem<
                                                                  String>(
                                                                value: 'update',
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Icon(Icons
                                                                        .edit),
                                                                    SizedBox(
                                                                        width:
                                                                            5),
                                                                    Text(
                                                                        'Güncelle'),
                                                                  ],
                                                                ),
                                                              ),
                                                              const PopupMenuItem<
                                                                  String>(
                                                                value: 'delete',
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Icon(Icons
                                                                        .delete),
                                                                    SizedBox(
                                                                        width:
                                                                            5),
                                                                    Text('Sil'),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : Container()
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      replyCount > 0
                                                          ? 'Yanıtlar: $replyCount'
                                                          : "Yanıt Ekle",
                                                      style: const TextStyle(
                                                          color:
                                                              Colors.black54),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: TextField(
                        controller: viewModel.commentController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: "Yorum yaz",
                          prefixIcon: const Icon(Icons.comment),
                          suffixIcon: IconButton(
                            onPressed: () async {
                              if (viewModel.isUpdate) {
                                await viewModel.updateComment(
                                  viewModel.commentIdForUpdate!,
                                  viewModel.commentController.text,
                                  receipt.id!,
                                  context,
                                );
                              } else {
                                await viewModel.addComment(
                                  receipt.id!,
                                  viewModel.commentController.text,
                                  "api/comments/add",
                                  context,
                                );
                              }
                            },
                            icon: const Icon(Icons.send),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteComment(
      BuildContext context,
      ReceiptDetailViewModel viewModel,
      int commentId,
      String path,
      int receiptId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yorumu Sil'),
          content: const Text('Bu yorumu silmek istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Evet'),
              onPressed: () async {
                Navigator.of(context).pop();
                await viewModel.deleteComment(
                    commentId, path, receiptId, context);
              },
            ),
            TextButton(
              child: const Text('Hayır'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
