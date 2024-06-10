import 'package:flutter/material.dart';
import 'package:colyakapp/QuizJson.dart';

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
    int correctCount = 0;

    for (int i = 0; i < questionList.length; i++) {
      if (chosenAnswers[i][i] == questionList[i].correctAnswer) {
        correctCount++;
      }
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context)
          ..pop()
          ..pop()
          ..pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(topicName),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context)
                ..pop()
                ..pop()
                ..pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 75,
                    height: 75,
                    child: CircularProgressIndicator(
                      value: (correctCount) / questionList.length,
                      strokeWidth: 8,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.green),
                      backgroundColor: Colors.red,
                    ),
                  ),
                  Text(
                    "$correctCount / ${questionList.length}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: questionList.length,
                itemBuilder: (context, index) {
                  final selectedAnswer = chosenAnswers[index][index];
                  final correctAnswer = questionList[index].correctAnswer;

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(
                        "${index + 1}) ${questionList[index].question}",
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
                        selectedAnswer == correctAnswer
                            ? Icons.check
                            : Icons.close,
                        color: selectedAnswer == correctAnswer
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
