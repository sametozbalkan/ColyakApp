import 'package:colyakapp/viewmodel/UserGuidesViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:colyakapp/screen/UserGuideScreen.dart';

class UserGuides extends StatelessWidget {
  const UserGuides({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserGuidesViewModel(),
      child: Consumer<UserGuidesViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Faydalı Bilgiler"),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.separated(
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          height: 5,
                        );
                      },
                      shrinkWrap: true,
                      itemCount: viewModel.pdflistesi.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserGuide(
                                  id: viewModel.pdflistesi[index].id!,
                                  name: viewModel.pdflistesi[index].name!,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: ListTile(
                                title: Text(viewModel.pdflistesi[index].name!),
                                trailing: const Icon(Icons.arrow_forward)),
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
