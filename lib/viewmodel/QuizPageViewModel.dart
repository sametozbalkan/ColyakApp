import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:colyakapp/service/HttpBuild.dart';
import 'package:colyakapp/model/QuizJson.dart';

class QuizPageViewModel extends ChangeNotifier {
  bool isLoading = false;
  List<QuizJson> quizler = [];
  bool _isMounted = true;

  QuizPageViewModel() {
    initializeData();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> initializeData() async {
    setLoading(true);
    await fetchQuizzes("api/quiz/all");
    setLoading(false);
  }

  Future<void> fetchQuizzes(String path) async {
    try {
      final response =
          await HttpBuildService.sendRequest('GET', path, token: true);

      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      quizler = data.map((json) => QuizJson.fromJson(json)).toList();
    } catch (e) {
      if (_isMounted) {
        debugPrint('Failed to load quizzes: $e');
      }
    }
    if (_isMounted) {
      notifyListeners();
    }
  }

  void setLoading(bool value) {
    if (_isMounted) {
      isLoading = value;
      notifyListeners();
    }
  }
}
