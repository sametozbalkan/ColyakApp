import 'package:colyakapp/viewmodel/QuizReportViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:colyakapp/model/QuizJson.dart';

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
    return ChangeNotifierProvider(
      create: (_) => QuizReportViewModel(
        chosenAnswers: chosenAnswers,
        questionList: questionList,
        topicName: topicName,
      ),
      child: Consumer<QuizReportViewModel>(
        builder: (context, viewModel, child) {
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
                title: Text(viewModel.topicName),
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
                            value: (viewModel.correctCount) /
                                viewModel.questionList.length,
                            strokeWidth: 8,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.green),
                            backgroundColor: Colors.red,
                          ),
                        ),
                        Text(
                          "${viewModel.correctCount} / ${viewModel.questionList.length}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: viewModel.questionList.length,
                      itemBuilder: (context, index) {
                        final selectedAnswer =
                            viewModel.chosenAnswers[index][index];
                        final correctAnswer =
                            viewModel.questionList[index].correctAnswer;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(
                              "${index + 1}) ${viewModel.questionList[index].question}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
        },
      ),
    );
  }
}
