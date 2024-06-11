import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:colyakapp/service/HttpBuild.dart';
import 'package:colyakapp/model/CommentReplyJson.dart';

class ReceiptDetailViewModel extends ChangeNotifier {
  List<CommentReplyJson> commentReply = [];
  TextEditingController commentController = TextEditingController();
  bool isLoading = true;
  bool liked = false;
  bool _isMounted = true;

  @override
  void dispose() {
    _isMounted = false;
    commentController.dispose();
    super.dispose();
  }

  Future<void> initializeData(int receiptId) async {
    await commentAl(
        "api/replies/receipt/commentsWithReplyByReceiptId/", receiptId);
  }

  Future<void> commentAl(String path, int receiptId) async {
    _setLoading(true);

    try {
      final response = await HttpBuildService.sendRequest(
          'GET', path + receiptId.toString(),
          token: true);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        commentReply =
            data.map((json) => CommentReplyJson.fromJson(json)).toList();
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching comments: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addComment(
      int receiptId, String comment, String path, BuildContext context) async {
    try {
      final Map<String, dynamic> commentDetails = {
        'receiptId': receiptId,
        'comment': comment,
      };

      final response = await HttpBuildService.sendRequest('POST', path,
          body: commentDetails, token: true);

      if (response.statusCode == 201) {
        await initializeData(receiptId);
        _showSnackBar('Yorum eklendi!', context);
        commentController.clear();
      } else {
        _showSnackBar('Yorum eklenirken hata: ${response.statusCode}', context);
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }

  Future<void> updateComment(int commentId, String comment, int receiptId,
      BuildContext context) async {
    try {
      final response = await HttpBuildService.sendRequest(
          'PUT', "api/comments/$commentId",
          body: comment, token: true);

      if (response.statusCode == 204) {
        await initializeData(receiptId);
        _showSnackBar('Yorum güncellendi!', context);
        commentController.clear();
      } else {
        _showSnackBar(
            'Yorum güncellenirken hata: ${response.statusCode}', context);
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating comment: $e');
    }
  }

  Future<void> deleteComment(
      int commentId, String path, int receiptId, BuildContext context) async {
    try {
      final response = await HttpBuildService.sendRequest(
          'DELETE', path + commentId.toString(),
          token: true);

      if (response.statusCode == 204) {
        await initializeData(receiptId);
      } else {
        _showSnackBar('Yorum silinirken hata: ${response.statusCode}', context);
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting comment: $e');
    }
  }

  Future<void> toggleLike(int receiptId, String path) async {
    try {
      final Map<String, dynamic> likeDetails = {
        'receiptId': receiptId,
      };

      final response = await HttpBuildService.sendRequest('POST', path,
          body: likeDetails, token: true);

      if (response.statusCode == 200 || response.statusCode == 201) {
        liked = !liked;
        if (_isMounted) notifyListeners();
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print('Error toggling like: $e');
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

  void _setLoading(bool value) {
    isLoading = value;
    if (_isMounted) notifyListeners();
  }

  void _showSnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
