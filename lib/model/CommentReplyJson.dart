class CommentReplyJson {
  CommentResponse? commentResponse;
  List<ReplyResponses>? replyResponses;

  CommentReplyJson({this.commentResponse, this.replyResponses});

  CommentReplyJson.fromJson(Map<String, dynamic> json) {
    commentResponse = json['commentResponse'] != null
        ? CommentResponse.fromJson(json['commentResponse'])
        : null;
    if (json['replyResponses'] != null) {
      replyResponses = <ReplyResponses>[];
      json['replyResponses'].forEach((v) {
        replyResponses!.add(ReplyResponses.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (commentResponse != null) {
      data['commentResponse'] = commentResponse!.toJson();
    }
    if (replyResponses != null) {
      data['replyResponses'] = replyResponses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CommentResponse {
  int? commentId;
  String? userName;
  String? receiptName;
  String? createdDate;
  String? comment;

  CommentResponse(
      {this.commentId,
      this.userName,
      this.receiptName,
      this.createdDate,
      this.comment});

  CommentResponse.fromJson(Map<String, dynamic> json) {
    commentId = json['commentId'];
    userName = json['userName'];
    receiptName = json['receiptName'];
    createdDate = json['createdDate'];
    comment = json['comment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['commentId'] = commentId;
    data['userName'] = userName;
    data['receiptName'] = receiptName;
    data['createdDate'] = createdDate;
    data['comment'] = comment;
    return data;
  }
}

class ReplyResponses {
  int? replyId;
  String? userName;
  String? createdDate;
  String? reply;

  ReplyResponses({this.replyId, this.userName, this.createdDate, this.reply});

  ReplyResponses.fromJson(Map<String, dynamic> json) {
    replyId = json['replyId'];
    userName = json['userName'];
    createdDate = json['createdDate'];
    reply = json['reply'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['replyId'] = replyId;
    data['userName'] = userName;
    data['createdDate'] = createdDate;
    data['reply'] = reply;
    return data;
  }
}
