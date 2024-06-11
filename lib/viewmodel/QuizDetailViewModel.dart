import 'dart:convert';
import 'dart:typed_data';
import 'package:colyakapp/screen/QuizReportScreen.dart';
import 'package:flutter/material.dart';
import 'package:colyakapp/cachemanager/CacheManager.dart';
import 'package:colyakapp/service/HttpBuild.dart';
import 'package:colyakapp/model/QuizJson.dart';
import 'package:http/http.dart' as http;

class QuizDetailViewModel extends ChangeNotifier {
  final List<QuestionList> questionList;
  final String topicName;

  int _currentQuestionIndex = 0;
  final Map<int, String?> _chosenAnswers = {};
  final List<Map<int, String?>> _allChosenAnswers = [];
  bool _isProcessing = false;
  bool _isLoading = true;
  Map<String, Uint8List?> imageBytesMap = {};

  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isProcessing => _isProcessing;
  bool get isLoading => _isLoading;
  Map<int, String?> get chosenAnswers => _chosenAnswers;
  List<Map<int, String?>> get allChosenAnswers => _allChosenAnswers;
  Map<String, Uint8List?> get imageBytes => imageBytesMap;

  QuizDetailViewModel({
    required this.questionList,
    required this.topicName,
  }) {
    _loadImageBytes(_currentQuestionIndex);
  }

  Future<void> _loadImageBytes(int questionIndex) async {
    _setLoading(true);

    List<Future<void>> futures = questionList[questionIndex]
        .choicesList!
        .where((choice) => choice.imageId != null)
        .map((choice) async {
      String imageUrl =
          "https://api.colyakdiyabet.com.tr/api/image/get/${choice.imageId}";
      if (!imageBytesMap.containsKey(imageUrl)) {
        Uint8List? bytes = await CacheManager().getImageBytes(imageUrl);
        if (bytes != null) {
          imageBytesMap[imageUrl] = bytes;
          notifyListeners();
        }
      }
    }).toList();

    await Future.wait(futures);

    _setLoading(false);
  }

  Future<void> nextQuestion(
      int questionId, String chosenAnswer, BuildContext context) async {
    if (_isProcessing) return;

    _setProcessing(true);

    final response = await quizSoruGonder(questionId, chosenAnswer);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      final bool correct = responseData['correct'];
      final String correctAnswer = responseData['correctAnswer'];

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(correct ? "Doğru" : "Yanlış"),
            content: Text(correct
                ? "Cevabınız doğru!"
                : "Cevabınız yanlış. Doğru cevap: $correctAnswer"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Tamam"),
              ),
            ],
          );
        },
      );

      _allChosenAnswers.add(Map.from(_chosenAnswers));

      if (_currentQuestionIndex < questionList.length - 1) {
        _currentQuestionIndex++;
        _chosenAnswers.clear();
        _loadImageBytes(_currentQuestionIndex);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizReportScreen(
              questionList: questionList,
              chosenAnswers: _allChosenAnswers,
              topicName: topicName,
            ),
          ),
        );
      }
    } else {
      print("Hata kodu: ${response.statusCode}");
    }

    _setProcessing(false);
  }

  Future<http.Response> quizSoruGonder(
      int questionId, String chosenAnswer) async {
    final quizDetails = {
      "questionId": questionId,
      "chosenAnswer": chosenAnswer,
    };

    return await HttpBuildService.sendRequest(
      'POST',
      'api/user-answer/submit-answer',
      body: quizDetails,
      token: true,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }

  void chooseAnswer(int questionIndex, String? choice) {
    _chosenAnswers[questionIndex] = choice;
    notifyListeners();
  }
}
