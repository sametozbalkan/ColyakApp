import 'dart:convert';
import 'package:colyakapp/CommentReplyJson.dart';
import 'package:colyakapp/HttpBuild.dart';
import 'package:flutter/material.dart';

class ReplyCommentScreen extends StatefulWidget {
  final int commentId;
  final String comment;
  final String commentUser;
  final String createdTime;
  final List<ReplyResponses> replies;

  const ReplyCommentScreen({
    super.key,
    required this.commentId,
    required this.comment,
    required this.commentUser,
    required this.createdTime,
    required this.replies,
  });

  @override
  State<ReplyCommentScreen> createState() => _ReplyCommentScreenState();
}

List<ReplyResponses> allReplies = [];

class _ReplyCommentScreenState extends State<ReplyCommentScreen> {
  @override
  void initState() {
    super.initState();
    allReplies = widget.replies;
  }

  Future<void> initializeData() async {
    try {
      final response = await sendRequest(
          'GET', 'api/replies/comments/${widget.commentId}',
          token: globaltoken, context: context);
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      if (mounted) {
        setState(() {
          allReplies =
              data.map((json) => ReplyResponses.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> updateReply(int replyId, String reply) async {
    try {
      final response = await sendRequest(
          'PUT', "api/replies/$replyId?newReply=$reply",
          token: globaltoken, context: context);

      if (response.statusCode == 204) {
        await initializeData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yanıt güncellendi!'),
            duration: Duration(seconds: 1),
          ),
        );
        replyYaz.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yanıt güncellenirken hata: ${response.statusCode}'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error updating comment: $e');
    }
  }

  Future<void> replyGonder(int commentId, String reply) async {
    try {
      final replyDetails = {'commentId': commentId, 'reply': reply};
      final response = await sendRequest('POST', 'api/replies/add',
          body: replyDetails, token: globaltoken, context: context);

      if (response.statusCode == 200) {
        await initializeData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yanıt eklendi!'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              children: [
                const Text('Yanıt eklenirken hata!'),
                Text(response.statusCode.toString()),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> replySil(int replyId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yanıtı Sil'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bu yanıtı silmek istediğinizden emin misiniz?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Evet'),
              onPressed: () async {
                await _deleteReply(replyId);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hayır'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteReply(int replyId) async {
    try {
      final response = await sendRequest('DELETE', 'api/replies/',
          extra: replyId.toString(), token: globaltoken, context: context);
      if (response.statusCode == 204) {
        await initializeData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yanıt silindi!'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e);
    }
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

  final TextEditingController replyYaz = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(child: _buildBody()),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(title: const Text("Yanıt Ekle"));
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildCommentCard(),
        Expanded(child: _buildRepliesSection()),
      ],
    );
  }

  Widget _buildCommentCard() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Card(
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.commentUser,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(timeSince(DateTime.parse(widget.createdTime))),
                ],
              ),
              const Divider(),
              Text(
                widget.comment,
                softWrap: true,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> confirmDeleteReply(index) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yanıtı Sil'),
          content: const Text('Bu yanıtı silmek istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Evet'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteReply(allReplies[index].replyId!);
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

  Widget _buildRepliesSection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Yanıtlar",
                style: TextStyle(fontSize: 20),
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: allReplies.length,
            itemBuilder: (context, index) {
              DateTime createdAt =
                  DateTime.parse(allReplies[index].createdDate!);
              return Padding(
                padding: const EdgeInsets.only(right: 5, left: 5, bottom: 5),
                child: Card(
                  child: Stack(children: [
                    Column(
                      children: [
                        ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    allReplies[index].userName.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(timeSince(createdAt))
                                ],
                              ),
                              const Divider(),
                              allReplies[index].userName != userName
                                  ? Text(allReplies[index].reply.toString(),
                                      softWrap: true)
                                  : Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: Text(
                                          allReplies[index].reply.toString(),
                                          softWrap: true),
                                    )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: allReplies[index].userName == userName
                          ? PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (String result) async {
                                if (result == 'delete') {
                                  await confirmDeleteReply(index);
                                } else if (result == 'update') {
                                  replyYaz.text = allReplies[index].reply!;
                                  await showModalUpdate(index);
                                }
                              },
                              itemBuilder: (BuildContext context) =>
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
                          : Container(),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
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
                  const Text('Yanıt Ekle'),
                  const SizedBox(height: 10),
                  const Divider(),
                  TextField(
                    maxLines: null,
                    controller: replyYaz,
                    decoration: InputDecoration(
                      labelText: "Yanıt yaz",
                      prefixIcon: const Icon(Icons.comment),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          await replyGonder(widget.commentId, replyYaz.text);
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
      },
      child: const Icon(Icons.add),
    );
  }

  Future showModalUpdate(index) {
    return showModalBottomSheet<dynamic>(
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
              const Text('Yanıt Düzenle'),
              const SizedBox(height: 10),
              const Divider(),
              TextField(
                maxLines: null,
                controller: replyYaz,
                decoration: InputDecoration(
                  labelText: "Yanıt yaz",
                  prefixIcon: const Icon(Icons.comment),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () async {
                      await updateReply(
                          allReplies[index].replyId!, replyYaz.text);
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
