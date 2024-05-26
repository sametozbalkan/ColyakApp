import 'dart:convert';
import 'dart:typed_data';
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
  bool _isProcessing = false;
  bool _isLoading = true;
  Map<String, Uint8List?> imageBytesMap = {};

  Future<void> _loadImageBytes(int questionIndex) async {
    setState(() {
      _isLoading = true;
    });

    for (var choice in widget.questionList[questionIndex].choicesList!) {
      int imageId = choice.imageId ?? 0;
      String imageUrl =
          "https://api.colyakdiyabet.com.tr/api/image/get/$imageId";
      if (!imageBytesMap.containsKey(imageUrl)) {
        var response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              imageBytesMap[imageUrl] = response.bodyBytes;
            });
          }
        } else {
          print('Resim alınamadı. Hata kodu: ${response.statusCode}');
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

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

  void _nextQuestion(int questionId, String chosenAnswer) async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

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
            content: Text(correct
                ? "Cevabınız doğru!"
                : "Cevabınız yanlış. Doğru cevap: $correctAnswer"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _allChosenAnswers.add(Map.from(_chosenAnswers));

                    if (_currentQuestionIndex <
                        widget.questionList.length - 1) {
                      _currentQuestionIndex++;
                      _chosenAnswers.clear();
                      _loadImageBytes(_currentQuestionIndex);
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

    setState(() {
      _isProcessing = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadImageBytes(_currentQuestionIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicName),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text("Yükleniyor...")
              ],
            ))
          : Padding(
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
                  Expanded(
                    child: ListView(
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
                              .map((entry) {
                            String imageUrl =
                                "https://api.colyakdiyabet.com.tr/api/image/get/${entry.value.imageId}";
                            return CheckboxListTile(
                              value: _chosenAnswers[_currentQuestionIndex] ==
                                  entry.value.choice,
                              onChanged: _isProcessing
                                  ? null
                                  : (value) async {
                                      setState(() {
                                        _chosenAnswers[_currentQuestionIndex] =
                                            entry.value.choice;
                                      });
                                      _nextQuestion(
                                          widget
                                              .questionList[
                                                  _currentQuestionIndex]
                                              .id!,
                                          entry.value.choice!);
                                    },
                              title: Text(entry.value.choice ?? ''),
                              controlAffinity: ListTileControlAffinity.leading,
                              secondary: imageBytesMap[imageUrl] != null
                                  ? AspectRatio(
                                      aspectRatio: 1 / 1,
                                      child: Image.memory(
                                          imageBytesMap[imageUrl]!),
                                    )
                                  : null,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
