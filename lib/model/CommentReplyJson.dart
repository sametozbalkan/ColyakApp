class CommentReplyJson {
  CommentResponse? commentResponse;
  List<ReplyResponse>? replyResponses;

  CommentReplyJson({this.commentResponse, this.replyResponses});

  CommentReplyJson.fromJson(Map<String, dynamic> json) {
    commentResponse = json['commentResponse'] != null
        ? CommentResponse.fromJson(json['commentResponse'])
        : null;
    if (json['replyResponses'] != null) {
      replyResponses = <ReplyResponse>[];
      json['replyResponses'].forEach((v) {
        replyResponses!.add(ReplyResponse.fromJson(v));
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

class ReplyResponse {
  int? replyId;
  String? userName;
  String? createdDate;
  String? reply;

  ReplyResponse({this.replyId, this.userName, this.createdDate, this.reply});

  ReplyResponse.fromJson(Map<String, dynamic> json) {
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
