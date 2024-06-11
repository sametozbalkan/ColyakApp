import 'package:colyakapp/viewmodel/UserGuideViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class UserGuide extends StatelessWidget {
  final int id;
  final String name;

  const UserGuide({super.key, required this.id, required this.name});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserGuideViewModel(id, name),
      child: Consumer<UserGuideViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(name),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.errorMessage != null
                    ? Center(child: Text('Error: ${viewModel.errorMessage}'))
                    : SfPdfViewer.memory(
                        viewModel.pdfData!,
                      ),
          );
        },
      ),
    );
  }
}
