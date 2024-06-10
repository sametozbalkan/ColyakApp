import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colyakapp/CommentReplyJson.dart';
import 'package:colyakapp/HttpBuild.dart';
import 'package:colyakapp/ReceiptJson.dart';
import 'package:colyakapp/ReplyCommentScreen.dart';
import 'package:colyakapp/Shimmer.dart';
import 'package:flutter/material.dart';

class ReceiptDetailScreen extends StatefulWidget {
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
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  List<CommentReplyJson> commentReply = [];
  TextEditingController commentController = TextEditingController();
  late bool liked;

  @override
  void initState() {
    super.initState();
    liked = widget.isLiked;
    initializeData();
  }

  Future<void> initializeData() async {
    await commentAl("api/replies/receipt/commentsWithReplyByReceiptId/");
  }

  bool isLoading = true;
  Future<void> commentAl(String path) async {
    isLoading = true;

    try {
      final response = await HttpBuildService.sendRequest(
          'GET', path + widget.receipt.id.toString(),
          token: true);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          commentReply =
              data.map((json) => CommentReplyJson.fromJson(json)).toList();
        });
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching comments: $e');
    }

    isLoading = false;
  }

  Future<void> addComment(int receiptId, String comment, String path) async {
    try {
      final Map<String, dynamic> commentDetails = {
        'receiptId': receiptId,
        'comment': comment,
      };

      final response = await HttpBuildService.sendRequest('POST', path,
          body: commentDetails, token: true);

      if (response.statusCode == 201) {
        await initializeData();
        showSnackBar('Yorum eklendi!');
        commentController.clear();
      } else {
        showSnackBar('Yorum eklenirken hata: ${response.statusCode}');
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }

  Future<void> updateComment(int commentId, String comment) async {
    try {
      final response = await HttpBuildService.sendRequest(
          'PUT', "api/comments/$commentId",
          body: comment, token: true);

      if (response.statusCode == 204) {
        await initializeData();
        showSnackBar('Yorum güncellendi!');
        commentController.clear();
      } else {
        showSnackBar('Yorum güncellenirken hata: ${response.statusCode}');
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating comment: $e');
    }
  }

  Future<void> deleteComment(int commentId, String path) async {
    try {
      final response = await HttpBuildService.sendRequest(
          'DELETE', path + commentId.toString(),
          token: true);

      if (response.statusCode == 204) {
        initializeData();
        showSnackBar('Yorum silindi!');
      } else {
        showSnackBar('Yorum silinirken hata: ${response.statusCode}');
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting comment: $e');
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> confirmDeleteComment(int commentId, String path) async {
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
                await deleteComment(commentId, path);
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

  String timeSince(DateTime date) {
    final seconds = DateTime.now().difference(date).inSeconds;

    var interval = seconds ~/ 31536000;
    if (interval >= 1) {
      return '$interval yıl';
    }

    interval = seconds ~/ 2592000;
    if (interval >= 1) {
      return '$interval ay';
    }

    interval = seconds ~/ 86400;
    if (interval >= 1) {
      return '$interval gün';
    }

    interval = seconds ~/ 3600;
    if (interval >= 1) {
      return '$interval saat';
    }

    interval = seconds ~/ 60;
    if (interval >= 1) {
      return '$interval dakika';
    }

    return '$seconds saniye';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, liked);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.receipt.receiptName.toString()),
          actions: [
            IconButton(
              onPressed: () async {
                liked
                    ? {
                        await toggleLike(
                            widget.receipt.id!, "api/likes/unlike", liked),
                      }
                    : {
                        await toggleLike(
                            widget.receipt.id!, "api/likes/like", liked),
                      };
              },
              icon: Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                color: liked ? Colors.red : Colors.black,
              ),
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, liked);
            },
          ),
        ),
        body: DefaultTabController(
          length: 4,
          initialIndex: 0,
          child: Column(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 4 / 3,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  placeholder: (context, url) => Shimmer(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fitWidth,
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
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Yorumlar",
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
                    _buildMaterialList(),
                    _buildRecipeDetails(),
                    _buildNutritionalValues(),
                    _buildComments(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialList() {
    return ListView.builder(
      itemCount: widget.receipt.receiptItems!.length,
      itemBuilder: (context, index) {
        var product = widget.receipt.receiptItems![index];
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

  Widget _buildRecipeDetails() {
    return ListView.builder(
      itemCount: widget.receipt.receiptDetails!.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text("${index + 1}- ${widget.receipt.receiptDetails![index]}"),
        );
      },
    );
  }

  Widget _buildNutritionalValues() {
    return ListView.builder(
      itemCount: widget.receipt.nutritionalValuesList?.length,
      itemBuilder: (context, index) {
        final nutritionalValue = widget.receipt.nutritionalValuesList![index];
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

  Widget _buildComments() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBS(false);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: initializeData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : commentReply.isEmpty
                ? const Center(child: Text("Henüz Yorum Yok"))
                : ListView.builder(
                    itemCount: commentReply.length,
                    itemBuilder: (context, index) {
                      final commentResponse =
                          commentReply[index].commentResponse;
                      final replyResponses = commentReply[index].replyResponses;
                      final replyCount = replyResponses?.length ?? 0;

                      return Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReplyCommentScreen(
                                  replies: commentReply[index].replyResponses!,
                                  commentId: commentResponse.commentId!,
                                  comment: commentResponse.comment ?? "null",
                                  commentUser: commentResponse.userName!,
                                  createdTime: commentResponse.createdDate!,
                                ),
                              ),
                            ).then((value) => setState(() {
                                  initializeData();
                                }));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: Stack(
                              children: [
                                Column(
                                  children: [
                                    ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  commentResponse!.userName
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                timeSince(DateTime.parse(
                                                    commentResponse
                                                        .createdDate!)),
                                              ),
                                            ],
                                          ),
                                          const Divider(),
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  commentResponse.comment
                                                      .toString(),
                                                  softWrap: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            replyCount > 0
                                                ? 'Yanıtlar: $replyCount'
                                                : "Yanıt Yok",
                                            style: const TextStyle(
                                                color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: commentResponse.userName ==
                                          HttpBuildService.userName
                                      ? PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert),
                                          onSelected: (String result) async {
                                            if (result == 'delete') {
                                              await confirmDeleteComment(
                                                commentResponse.commentId!,
                                                "api/comments/",
                                              );
                                            } else if (result == 'update') {
                                              showModalBS(true,
                                                  commentResponse:
                                                      commentResponse);
                                            }
                                          },
                                          itemBuilder: (BuildContext context) =>
                                              <PopupMenuEntry<String>>[
                                            const PopupMenuItem<String>(
                                              value: 'update',
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.edit),
                                                  SizedBox(width: 5),
                                                  Text('Güncelle'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'delete',
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.delete),
                                                  SizedBox(width: 5),
                                                  Text('Sil'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
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
          liked = isLiked;
        });
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

  void showModalBS(bool isUpdate, {CommentResponse? commentResponse}) {
    commentController.text = isUpdate ? commentResponse!.comment! : '';
    final String title = isUpdate ? 'Yorumu Güncelle' : 'Yorum Ekle';

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 10,
            right: 10,
            top: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text(title, style: const TextStyle(fontSize: 18)),
              ),
              const Divider(),
              TextField(
                maxLines: null,
                controller: commentController,
                decoration: InputDecoration(
                  labelText: "Yorum yaz",
                  prefixIcon: const Icon(Icons.comment),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () async {
                      if (isUpdate) {
                        await updateComment(commentResponse!.commentId!,
                            commentController.text);
                      } else {
                        await addComment(widget.receipt.id!,
                            commentController.text, "api/comments/add");
                      }
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.send),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
