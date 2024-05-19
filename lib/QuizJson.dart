class QuizJson {
  int? id;
  String? topicName;
  List<QuestionList>? questionList;
  bool? deleted;

  QuizJson({this.id, this.topicName, this.questionList, this.deleted});

  QuizJson.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    topicName = json['topicName'];
    if (json['questionList'] != null) {
      questionList = <QuestionList>[];
      json['questionList'].forEach((v) {
        questionList!.add(QuestionList.fromJson(v));
      });
    }
    deleted = json['deleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['topicName'] = topicName;
    if (questionList != null) {
      data['questionList'] = questionList!.map((v) => v.toJson()).toList();
    }
    data['deleted'] = deleted;
    return data;
  }
}

class QuestionList {
  int? id;
  String? question;
  List<ChoicesList>? choicesList;
  String? correctAnswer;

  QuestionList({this.id, this.question, this.choicesList, this.correctAnswer});

  QuestionList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    if (json['choicesList'] != null) {
      choicesList = <ChoicesList>[];
      json['choicesList'].forEach((v) {
        choicesList!.add(ChoicesList.fromJson(v));
      });
    }
    correctAnswer = json['correctAnswer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['question'] = question;
    if (choicesList != null) {
      data['choicesList'] = choicesList!.map((v) => v.toJson()).toList();
    }
    data['correctAnswer'] = correctAnswer;
    return data;
  }
}

class ChoicesList {
  int? id;
  String? choice;
  int? imageId;

  ChoicesList({this.id, this.choice, this.imageId});

  ChoicesList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    choice = json['choice'];
    imageId = json['imageId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['choice'] = choice;
    data['imageId'] = imageId;
    return data;
  }
}

class QuizAnswerJson {
  int? userId;
  int? questionId;
  String? chosenAnswer;
  String? userName;
  String? questionText;
  String? correctAnswer;
  bool? correct;

  QuizAnswerJson(
      {this.userId,
      this.questionId,
      this.chosenAnswer,
      this.userName,
      this.questionText,
      this.correctAnswer,
      this.correct});

  QuizAnswerJson.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    questionId = json['questionId'];
    chosenAnswer = json['chosenAnswer'];
    userName = json['userName'];
    questionText = json['questionText'];
    correctAnswer = json['correctAnswer'];
    correct = json['correct'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['questionId'] = questionId;
    data['chosenAnswer'] = chosenAnswer;
    data['userName'] = userName;
    data['questionText'] = questionText;
    data['correctAnswer'] = correctAnswer;
    data['correct'] = correct;
    return data;
  }
}

