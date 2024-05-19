import 'dart:convert';
import 'package:colyakapp/HttpBuild.dart';
import 'package:colyakapp/QuizDetailScreen.dart';
import 'package:colyakapp/QuizJson.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

List<QuizJson> quizler = [];

class _QuizScreenState extends State<QuizScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    setState(() {
      isLoading = true;
    });
    await quizAl("api/quiz/all");
    setState(() {
      isLoading = false;
    });
  }

  Future<void> quizAl(String path) async {
    try {
      final response =
          await sendRequest('GET', path, token: globaltoken, context: context);

      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        quizler = data.map((json) => QuizJson.fromJson(json)).toList();
      });
    } catch (e) {
      print('Failed to load quizzes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quizler"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 10);
                },
                itemCount: quizler.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizDetailScreen(
                            questionList: quizler[index].questionList!,
                            topicName: quizler[index].topicName!,
                          ),
                        ),
                      ).then((value) => setState(() {}));
                    },
                    child: Card(
                      child: ListTile(
                        title: Text(
                          quizler[index].topicName!,
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: QuizScreen(),
  ));
}
