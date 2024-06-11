import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:colyakapp/service/HttpBuild.dart';
import 'package:colyakapp/model/CommentReplyJson.dart';

class ReplyCommentViewModel extends ChangeNotifier {
  final int commentId;
  final String comment;
  final String commentUser;
  final String createdTime;
  List<ReplyResponse> replies;

  bool isLoading = false;
  final TextEditingController replyController = TextEditingController();

  ReplyCommentViewModel({
    required this.commentId,
    required this.comment,
    required this.commentUser,
    required this.createdTime,
    required this.replies,
  });

  Future<void> initializeData() async {
    setLoading(true);
    try {
      final response = await HttpBuildService.sendRequest(
          'GET', 'api/replies/comments/$commentId',
          token: true);
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      replies = data.map((json) => ReplyResponse.fromJson(json)).toList();
    } catch (e) {
      print('Failed to load replies: $e');
    }
    setLoading(false);
  }

  Future<void> updateReply(int replyId, String reply) async {
    try {
      final response = await HttpBuildService.sendRequest(
          'PUT', "api/replies/$replyId?newReply=$reply",
          token: true);

      if (response.statusCode == 204) {
        await initializeData();
        showSnackBar('Yanıt güncellendi!');
        replyController.clear();
      } else {
        showSnackBar('Yanıt güncellenirken hata: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating comment: $e');
    }
  }

  Future<void> sendReply(String reply) async {
    try {
      final replyDetails = {'commentId': commentId, 'reply': reply};
      final response = await HttpBuildService.sendRequest(
          'POST', 'api/replies/add',
          body: replyDetails, token: true);

      if (response.statusCode == 200) {
        await initializeData();
        showSnackBar('Yanıt eklendi!');
      } else {
        showSnackBar('Yanıt eklenirken hata: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteReply(int replyId) async {
    try {
      final response = await HttpBuildService.sendRequest(
          'DELETE', 'api/replies/$replyId',
          token: true);
      if (response.statusCode == 204) {
        await initializeData();
        showSnackBar('Yanıt silindi!');
      } else {
        print('Error deleting reply: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting reply: $e');
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

  void showSnackBar(String message) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
