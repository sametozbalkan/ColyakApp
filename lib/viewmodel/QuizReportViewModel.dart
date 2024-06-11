import 'package:flutter/material.dart';
import 'package:colyakapp/model/QuizJson.dart';

class QuizReportViewModel extends ChangeNotifier {
  final List<Map<int, String?>> chosenAnswers;
  final List<QuestionList> questionList;
  final String topicName;

  int correctCount = 0;

  QuizReportViewModel({
    required this.chosenAnswers,
    required this.questionList,
    required this.topicName,
  }) {
    _calculateCorrectAnswers();
  }

  void _calculateCorrectAnswers() {
    for (int i = 0; i < questionList.length; i++) {
      if (chosenAnswers[i][i] == questionList[i].correctAnswer) {
        correctCount++;
      }
    }
    notifyListeners();
  }
}
