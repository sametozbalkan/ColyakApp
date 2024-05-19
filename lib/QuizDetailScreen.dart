import 'dart:convert';
import 'package:colyakapp/HttpBuild.dart';
import 'package:colyakapp/QuizJson.dart';
import 'package:colyakapp/QuizReportScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QuizDetailScreen extends StatefulWidget {
  final List<QuestionList> questionList;
  final String topicName;

  const QuizDetailScreen({
    required this.questionList,
    required this.topicName,
    super.key,
  });

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  int _currentQuestionIndex = 0;
  Map<int, String?> _chosenAnswers = {};

  List<Map<int, String?>> _allChosenAnswers = [];

  Future<http.Response> quizSoruGonder(
      int questionId, String chosenAnswer) async {
    final quizDetails = {
      "questionId": questionId,
      "chosenAnswer": chosenAnswer,
    };

    final response = await http.post(
      Uri.parse("${genelUrl}api/user-answer/submit-answer"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        'Authorization': 'Bearer $globaltoken',
      },
      body: json.encode(quizDetails),
    );

    return response;
  }

  bool _isProcessing = false;

  void _nextQuestion(int questionId, String chosenAnswer) async {
    if (_isProcessing) {
      return;
    }

    _isProcessing = true;

    for (int i = 0;
        i < widget.questionList[_currentQuestionIndex].choicesList!.length;
        i++) {
      if (i != _currentQuestionIndex) {
        _chosenAnswers[i] = null;
      }
    }

    final response = await quizSoruGonder(questionId, chosenAnswer);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData =
          json.decode(utf8.decode(response.bodyBytes));
      final bool correct = responseData['correct'];
      final String correctAnswer = responseData['correctAnswer'];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(correct ? "Doğru" : "Yanlış"),
            content: Text(
                correct
                    ? "Cevabınız doğru!"
                    : "Cevabınız yanlış. Doğru cevap: $correctAnswer",
                softWrap: true),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    if (_currentQuestionIndex <
                        widget.questionList.length - 1) {
                      _currentQuestionIndex++;
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizReportScreen(
                            questionList: widget.questionList,
                            chosenAnswers: _allChosenAnswers,
                            topicName: widget.topicName,
                          ),
                        ),
                      );
                    }
                  });
                },
                child: const Text("Tamam"),
              ),
            ],
          );
        },
      );
    } else {
      print("Hata kodu: ${response.statusCode}");
    }

    _allChosenAnswers.add(Map.from(_chosenAnswers));

    _isProcessing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${_currentQuestionIndex + 1} / ${widget.questionList.length}",
                style: const TextStyle(fontSize: 16),
              ),
            ),
            ListView(
              shrinkWrap: true,
              children: [
                Text(
                  "${_currentQuestionIndex + 1}) ${widget.questionList[_currentQuestionIndex].question!}?",
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget
                      .questionList[_currentQuestionIndex].choicesList!
                      .asMap()
                      .entries
                      .map((entry) => CheckboxListTile(
                            value: _chosenAnswers[_currentQuestionIndex] ==
                                entry.value.choice,
                            onChanged: (value) async {
                              setState(() {
                                _chosenAnswers[_currentQuestionIndex] =
                                    entry.value.choice;
                              });
                              _nextQuestion(
                                  widget
                                      .questionList[_currentQuestionIndex].id!,
                                  entry.value.choice!);
                            },
                            title: Text(entry.value.choice ?? ''),
                            controlAffinity: ListTileControlAffinity.leading,
                          ))
                      .toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
