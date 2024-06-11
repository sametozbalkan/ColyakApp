import 'package:colyakapp/viewmodel/QuizPageViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:colyakapp/screen/QuizDetailScreen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuizPageViewModel(),
      child: Consumer<QuizPageViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Quizler"),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.separated(
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 10);
                      },
                      itemCount: viewModel.quizler.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizDetailScreen(
                                  questionList:
                                      viewModel.quizler[index].questionList!,
                                  topicName:
                                      viewModel.quizler[index].topicName!,
                                ),
                              ),
                            ).then((value) => viewModel.initializeData());
                          },
                          child: Card(
                            child: ListTile(
                              title: Text(
                                viewModel.quizler[index].topicName!,
                              ),
                              trailing: const Icon(Icons.arrow_forward),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          );
        },
      ),
    );
  }
}
