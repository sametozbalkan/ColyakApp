import 'package:colyakapp/QuizJson.dart';
import 'package:flutter/material.dart';

class QuizReportScreen extends StatelessWidget {
  final List<Map<int, String?>> chosenAnswers;
  final List<QuestionList> questionList;
  final String topicName;

  const QuizReportScreen({
    super.key,
    required this.chosenAnswers,
    required this.questionList,
    required this.topicName,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/homepage', (Route<dynamic> route) => false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(topicName),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/homepage', (Route<dynamic> route) => false);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: ListView.builder(
          itemCount: questionList.length,
          itemBuilder: (context, index) {
            final selectedAnswer = chosenAnswers[index][index];
            final correctAnswer = questionList[index].correctAnswer;

            return Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ListTile(
                title: Text(
                  "${index + 1}) ${questionList[index].question}?",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8.0),
                    Text("Sizin Cevabınız: $selectedAnswer"),
                    const SizedBox(height: 4.0),
                    Text("Doğru Cevap: $correctAnswer"),
                  ],
                ),
                trailing: Icon(
                  selectedAnswer == correctAnswer ? Icons.check : Icons.close,
                  color: selectedAnswer == correctAnswer
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}