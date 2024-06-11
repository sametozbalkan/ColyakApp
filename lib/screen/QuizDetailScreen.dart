import 'package:colyakapp/model/QuizJson.dart';
import 'package:colyakapp/viewmodel/QuizDetailViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class QuizDetailScreen extends StatelessWidget {
  final List<QuestionList> questionList;
  final String topicName;

  const QuizDetailScreen({
    required this.questionList,
    required this.topicName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuizDetailViewModel(
        questionList: questionList,
        topicName: topicName,
      ),
      child: Consumer<QuizDetailViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(viewModel.topicName),
            ),
            body: viewModel.isLoading
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
                                value: (viewModel.currentQuestionIndex + 1) /
                                    viewModel.questionList.length,
                                strokeWidth: 8,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFFF7A37)),
                                backgroundColor: Colors.grey[300],
                              ),
                            ),
                            Text(
                              "${viewModel.currentQuestionIndex + 1} / ${viewModel.questionList.length}",
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
                              _buildQuestionText(viewModel),
                              _buildChoices(context, viewModel),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionText(QuizDetailViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(11),
      child: Text(
        "${viewModel.currentQuestionIndex + 1}) ${viewModel.questionList[viewModel.currentQuestionIndex].question!}",
        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildChoices(BuildContext context, QuizDetailViewModel viewModel) {
    List<Widget> choicesWidgets = viewModel
        .questionList[viewModel.currentQuestionIndex].choicesList!
        .asMap()
        .entries
        .map((entry) {
      String imageUrl =
          "https://api.colyakdiyabet.com.tr/api/image/get/${entry.value.imageId}";
      return Card(
        child: Column(
          children: [
            if (entry.value.imageId != null) const SizedBox(height: 10),
            if (entry.value.imageId != null && viewModel.imageBytes[imageUrl] != null)
              Expanded(
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.memory(
                    viewModel.imageBytes[imageUrl]!,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            CheckboxListTile(
              value: viewModel.chosenAnswers[viewModel.currentQuestionIndex] ==
                  entry.value.choice,
              onChanged: viewModel.isProcessing
                  ? null
                  : (value) async {
                      viewModel.chooseAnswer(viewModel.currentQuestionIndex, entry.value.choice);
                      await viewModel.nextQuestion(
                          viewModel.questionList[viewModel.currentQuestionIndex].id!,
                          entry.value.choice!,
                          context);
                    },
              title: Text(entry.value.choice ?? ''),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      );
    }).toList();

    return viewModel.questionList[viewModel.currentQuestionIndex].choicesList!
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
}
