import 'dart:convert';
import 'dart:typed_data';
import 'package:colyakapp/CommentReplyJson.dart';
import 'package:colyakapp/HttpBuild.dart';
import 'package:colyakapp/ReceiptReadyFoodsJson.dart';
import 'package:colyakapp/ReplyCommentScreen.dart';
import 'package:flutter/material.dart';

class ReceiptDetailScreen extends StatefulWidget {
  final ReceiptJson receipt;
  final Uint8List imageBytes;
  final bool isLiked;
  final Function updateFavorites;

  const ReceiptDetailScreen({
    super.key,
    required this.receipt,
    required this.imageBytes,
    required this.isLiked,
    required this.updateFavorites,
  });

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  bool isLiked = false;
  List<CommentReplyJson> commentReply = [];
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.isLiked;
    initializeData();
  }

  Future<void> initializeData() async {
    await commentAl("api/replies/receipt/commentsWithReplyByReceiptId/");
  }

  Future<void> commentAl(String path) async {
    try {
      final response = await sendRequest(
          'GET', path + widget.receipt.id.toString(),
          token: globaltoken, context: context);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          commentReply =
              data.map((json) => CommentReplyJson.fromJson(json)).toList();
        });
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  Future<void> addComment(int receiptId, String comment, String path) async {
    try {
      final Map<String, dynamic> commentDetails = {
        'receiptId': receiptId,
        'comment': comment,
      };

      final response = await sendRequest('POST', path,
          body: commentDetails, token: globaltoken, context: context);

      if (response.statusCode == 201) {
        await initializeData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yorum eklendi!'),
            duration: Duration(seconds: 1),
          ),
        );
        commentController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorum eklenirken hata: ${response.statusCode}'),
            duration: const Duration(seconds: 1),
          ),
        );
        print(response.statusCode);
      }
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  Future<void> updateComment(int commentId, String comment) async {
    try {

      final response = await sendRequest('PUT', "api/comments/$commentId",
          body: comment, token: globaltoken, context: context);

      if (response.statusCode == 204) {
        await initializeData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yorum güncellendi!'),
            duration: Duration(seconds: 1),
          ),
        );
        commentController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorum güncellenirken hata: ${response.statusCode}'),
            duration: const Duration(seconds: 1),
          ),
        );
        print(response.statusCode);
      }
    } catch (e) {
      print('Error updating comment: $e');
    }
  }

  Future<void> toggleLike(int receiptId, String path) async {
    try {
      final Map<String, dynamic> likeDetails = {
        'receiptId': receiptId,
      };

      final response = await sendRequest('POST', path,
          body: likeDetails, token: globaltoken, context: context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isLiked = !isLiked;
        });
        widget.updateFavorites();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                isLiked ? 'Favorilere eklendi!' : 'Favorilerden kaldırıldı!'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<void> deleteComment(int commentId, String path) async {
    try {
      final response = await sendRequest('DELETE', path + commentId.toString(),
          token: globaltoken, context: context);

      if (response.statusCode == 204) {
        initializeData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yorum silindi!'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorum silinirken hata: ${response.statusCode}'),
            duration: const Duration(seconds: 1),
          ),
        );
        print(response.statusCode);
      }
    } catch (e) {
      print('Error deleting comment: $e');
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receipt.receiptName.toString()),
        actions: [
          IconButton(
            onPressed: () async {
              isLiked
                  ? await toggleLike(widget.receipt.id!, "api/likes/unlike")
                  : await toggleLike(widget.receipt.id!, "api/likes/like");
            },
            icon: Icon(
              Icons.favorite,
              color: isLiked ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        initialIndex: 0,
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.memory(widget.imageBytes, fit: BoxFit.fill),
            ),
            const TabBar(
              indicatorColor: Color(0xFFFF7A37),
              labelColor: Color(0xFFFF7A37),
              unselectedLabelColor: Colors.black,
              tabs: [
                Tab(
                    child: Text(
                  "Malzeme\nListesi",
                  textAlign: TextAlign.center,
                )),
                Tab(
                    child: Text(
                  "Tarif\nDetayları",
                  textAlign: TextAlign.center,
                )),
                Tab(
                    child: Text(
                  "Besin\nDeğerleri",
                  textAlign: TextAlign.center,
                )),
                Tab(text: 'Yorumlar'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  ListView.builder(
                    itemCount: widget.receipt.receiptItems!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                  "${widget.receipt.receiptItems![index].productName}"),
                            ),
                            Text(
                                "${widget.receipt.receiptItems![index].unit! % 1 == 0 ? widget.receipt.receiptItems![index].unit!.toInt().toString() : widget.receipt.receiptItems![index].unit!.toStringAsFixed(1)} ${widget.receipt.receiptItems![index].type}")
                          ],
                        ),
                      );
                    },
                  ),
                  ListView.builder(
                    itemCount: widget.receipt.receiptDetails!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            "${index + 1}- ${widget.receipt.receiptDetails![index]}."),
                      );
                    },
                  ),
                  ListView.builder(
                    itemCount: widget.receipt.nutritionalValuesList?.length,
                    itemBuilder: (context, index) {
                      final nutritionalValue =
                          widget.receipt.nutritionalValuesList![index];
                      return Card(
                        child: ListTile(
                          title: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(nutritionalValue.type ?? ""),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Kalori (kcal):"),
                                  Text(nutritionalValue.calorieAmount
                                      .toString()),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Karbonhidrat (g):"),
                                  Text(nutritionalValue.carbohydrateAmount
                                      .toString()),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Protein (g):"),
                                  Text(nutritionalValue.proteinAmount
                                      .toString()),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                  ),
                  Scaffold(
                      floatingActionButton: FloatingActionButton(
                        onPressed: () {
                          showModal();
                        },
                        child: const Icon(Icons.add),
                      ),
                      body: ListView.builder(
                        itemCount: commentReply.length,
                        itemBuilder: (context, index) {
                          final commentResponse =
                              commentReply[index].commentResponse;
                          final replyResponses =
                              commentReply[index].replyResponses;
                          final replyCount = replyResponses?.length ?? 0;

                          return Card(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReplyCommentScreen(
                                      replies:
                                          commentReply[index].replyResponses!,
                                      commentId: commentResponse.commentId!,
                                      comment: commentResponse.comment == null ? "null" : commentResponse.comment!,
                                      commentUser: commentResponse.userName!,
                                      createdTime: commentResponse.createdDate!,
                                    ),
                                  ),
                                ).then((value) => setState(() {
                                      initializeData();
                                    }));
                              },
                              child: Column(
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
                                            Text(
                                              commentResponse!.userName
                                                  .toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
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
                                    trailing: commentResponse.userName ==
                                            userName
                                        ? PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert),
                                            onSelected: (String result) async {
                                              if (result == 'delete') {
                                                await confirmDeleteComment(
                                                  commentResponse.commentId!,
                                                  "api/comments/",
                                                );
                                              } else if (result == 'update') {
                                                showModalUpdate(
                                                    commentResponse);
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) =>
                                                    <PopupMenuEntry<String>>[
                                              const PopupMenuItem<String>(
                                                value: 'update',
                                                child: Text('Güncelle'),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Text('Sil'),
                                              ),
                                            ],
                                          )
                                        : null,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
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
                            ),
                          );
                        },
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showModal() {
    showModalBottomSheet<dynamic>(
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
              const Text('Yorum Ekle'),
              const SizedBox(height: 10),
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
                      await addComment(widget.receipt.id!,
                          commentController.text, "api/comments/add");
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

  void showModalUpdate(CommentResponse commentResponse) {
    commentController.text = commentResponse.comment!;
    showModalBottomSheet<dynamic>(
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
              const Text('Yorumu Güncelle'),
              const SizedBox(height: 10),
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
                      await updateComment(
                          commentResponse.commentId!, commentController.text);
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
