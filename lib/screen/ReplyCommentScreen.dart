import 'package:colyakapp/model/CommentReplyJson.dart';
import 'package:colyakapp/service/HttpBuild.dart';
import 'package:colyakapp/viewmodel/ReplyCommentViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReplyCommentScreen extends StatelessWidget {
  final int commentId;
  final String comment;
  final String commentUser;
  final String createdTime;
  final List<ReplyResponse> replies;

  const ReplyCommentScreen({
    super.key,
    required this.commentId,
    required this.comment,
    required this.commentUser,
    required this.createdTime,
    required this.replies,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReplyCommentViewModel(
        commentId: commentId,
        comment: comment,
        commentUser: commentUser,
        createdTime: createdTime,
        replies: replies,
      ),
      child: Consumer<ReplyCommentViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(title: const Text("Yanıt Ekle")),
            body: SafeArea(child: _buildBody(context, viewModel)),
            floatingActionButton:
                _buildFloatingActionButton(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReplyCommentViewModel viewModel) {
    return Column(
      children: [
        _buildCommentCard(viewModel),
        Expanded(child: _buildRepliesSection(context, viewModel)),
      ],
    );
  }

  Widget _buildCommentCard(ReplyCommentViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      viewModel.commentUser,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(viewModel
                        .timeSince(DateTime.parse(viewModel.createdTime))),
                  ],
                ),
                const Divider(),
                Text(
                  viewModel.comment,
                  softWrap: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRepliesSection(
      BuildContext context, ReplyCommentViewModel viewModel) {
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
        viewModel.replies.isEmpty
            ? const Expanded(
                child: Center(
                  child: Text("Henüz Yanıt Yok"),
                ),
              )
            : Expanded(
                child: RefreshIndicator(
                  onRefresh: viewModel.initializeData,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: viewModel.replies.length,
                    itemBuilder: (context, index) {
                      DateTime createdAt =
                          DateTime.parse(viewModel.replies[index].createdDate!);
                      return Padding(
                        padding:
                            const EdgeInsets.only(right: 5, left: 5, bottom: 5),
                        child: Stack(
                          children: [
                            Card(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Stack(children: [
                                  Column(
                                    children: [
                                      ListTile(
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  viewModel
                                                      .replies[index].userName
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 5, right: 5),
                                                  child: Icon(Icons.circle,
                                                      size: 6,
                                                      color: Colors.black),
                                                ),
                                                Text(viewModel
                                                    .timeSince(createdAt))
                                              ],
                                            ),
                                            const Divider(),
                                            viewModel.replies[index].userName !=
                                                    HttpBuildService.userName
                                                ? Text(
                                                    viewModel
                                                        .replies[index].reply
                                                        .toString(),
                                                    softWrap: true)
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 16),
                                                    child: Text(
                                                        viewModel.replies[index]
                                                            .reply
                                                            .toString(),
                                                        softWrap: true),
                                                  )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ]),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: viewModel.replies[index].userName ==
                                      HttpBuildService.userName
                                  ? PopupMenuButton<String>(
                                      color: Colors.white,
                                      icon: const Icon(Icons.more_horiz),
                                      onSelected: (String result) async {
                                        if (result == 'delete') {
                                          await _confirmDeleteReply(
                                              context, viewModel, index);
                                        } else if (result == 'update') {
                                          viewModel.replyController.text =
                                              viewModel.replies[index].reply!;
                                          await showModalUpdate(
                                              context, viewModel, index);
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
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildFloatingActionButton(
      BuildContext context, ReplyCommentViewModel viewModel) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          backgroundColor: Colors.white,
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
                  const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text('Yanıt Ekle', style: TextStyle(fontSize: 18)),
                  ),
                  const Divider(),
                  TextField(
                    maxLines: null,
                    controller: viewModel.replyController,
                    decoration: InputDecoration(
                      labelText: "Yanıt yaz",
                      prefixIcon: const Icon(Icons.comment),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          await viewModel
                              .sendReply(viewModel.replyController.text);
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

  Future<void> _confirmDeleteReply(
      BuildContext context, ReplyCommentViewModel viewModel, int index) async {
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
                await viewModel.deleteReply(viewModel.replies[index].replyId!);
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

  Future<void> showModalUpdate(
      BuildContext context, ReplyCommentViewModel viewModel, int index) {
    return showModalBottomSheet(
      backgroundColor: Colors.white,
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
              const Padding(
                padding: EdgeInsets.only(bottom: 10, top: 10),
                child: Text('Yanıt Düzenle', style: TextStyle(fontSize: 18)),
              ),
              const Divider(),
              TextField(
                maxLines: null,
                controller: viewModel.replyController,
                decoration: InputDecoration(
                  labelText: "Yanıt yaz",
                  prefixIcon: const Icon(Icons.comment),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () async {
                      await viewModel.updateReply(
                          viewModel.replies[index].replyId!,
                          viewModel.replyController.text);
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
