import 'dart:convert';
import 'dart:typed_data';
import 'package:colyakapp/CacheManager.dart';
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

  @override
  void initState() {
    super.initState();
    _loadImageBytes(_currentQuestionIndex);
  }

  Future<void> _loadImageBytes(int questionIndex) async {
    setState(() {
      _isLoading = true;
    });

    List<Future<void>> futures = widget.questionList[questionIndex].choicesList!
        .where((choice) => choice.imageId != null)
        .map((choice) async {
      String imageUrl =
          "https://api.colyakdiyabet.com.tr/api/image/get/${choice.imageId}";
      if (!imageBytesMap.containsKey(imageUrl)) {
        Uint8List? bytes = await CacheManager().getImageBytes(imageUrl);
        if (bytes != null && mounted) {
          setState(() {
            imageBytesMap[imageUrl] = bytes;
          });
        } else {
          print('Resim alınamadı.');
        }
      }
    }).toList();

    await Future.wait(futures);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _nextQuestion(int questionId, String chosenAnswer) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    final response = await quizSoruGonder(questionId, chosenAnswer, context);

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

      setState(() {
        _allChosenAnswers.add(Map.from(_chosenAnswers));

        if (_currentQuestionIndex < widget.questionList.length - 1) {
          _currentQuestionIndex++;
          _chosenAnswers.clear();
          _loadImageBytes(_currentQuestionIndex);
        } else {
          Navigator.push(
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
    } else {
      print("Hata kodu: ${response.statusCode}");
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Future<http.Response> quizSoruGonder(
      int questionId, String chosenAnswer, BuildContext context) async {
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

  Widget _buildQuestionText() {
    return Padding(
      padding: const EdgeInsets.all(11),
      child: Text(
        "${_currentQuestionIndex + 1}) ${widget.questionList[_currentQuestionIndex].question!}",
        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildChoices() {
    List<Widget> choicesWidgets = widget
        .questionList[_currentQuestionIndex].choicesList!
        .asMap()
        .entries
        .map((entry) {
      String imageUrl =
          "https://api.colyakdiyabet.com.tr/api/image/get/${entry.value.imageId}";
      return Card(
        child: Column(
          children: [
            if (entry.value.imageId != null) const SizedBox(height: 10),
            if (entry.value.imageId != null && imageBytesMap[imageUrl] != null)
              Expanded(
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.memory(
                    imageBytesMap[imageUrl]!,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            CheckboxListTile(
              value:
                  _chosenAnswers[_currentQuestionIndex] == entry.value.choice,
              onChanged: _isProcessing
                  ? null
                  : (value) async {
                      setState(() {
                        _chosenAnswers[_currentQuestionIndex] =
                            entry.value.choice;
                      });
                      await _nextQuestion(
                          widget.questionList[_currentQuestionIndex].id!,
                          entry.value.choice!);
                    },
              title: Text(entry.value.choice ?? ''),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      );
    }).toList();

    return widget.questionList[_currentQuestionIndex].choicesList!
            .any((choice) => choice.imageId != null)
        ? GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: choicesWidgets,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: choicesWidgets,
          );
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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 75,
                        height: 75,
                        child: CircularProgressIndicator(
                          value: (_currentQuestionIndex + 1) /
                              widget.questionList.length,
                          strokeWidth: 8,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF7A37)),
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                      Text(
                        "${_currentQuestionIndex + 1} / ${widget.questionList.length}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildQuestionText(),
                        _buildChoices(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}