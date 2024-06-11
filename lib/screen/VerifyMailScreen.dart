import 'package:colyakapp/viewmodel/VerifyMailViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class VerifyMailScreen extends StatelessWidget {
  final String? verificationId;

  const VerifyMailScreen({super.key, this.verificationId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VerifyMailViewModel(verificationId),
      child: Consumer<VerifyMailViewModel>(
        builder: (context, viewModel, child) {
          return WillPopScope(
            onWillPop: () => viewModel.onWillPop(context),
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Email Doğrulama'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    bool shouldPop = await viewModel.onWillPop(context);
                    if (shouldPop) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
              body: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset("assets/images/colyak.png",
                          height: MediaQuery.of(context).size.width / 1.5,
                          width: MediaQuery.of(context).size.width / 1.5),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Stack(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Tek Seferlik Email Onay Kodu"),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: viewModel.isPasteVisible
                                    ? IconButton(
                                        onPressed: () =>
                                            viewModel.handlePaste(context),
                                        icon: const Icon(Icons.paste),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 50,
                              child: TextField(
                                controller: viewModel.controllers[index],
                                focusNode: viewModel.focusNodes[index],
                                maxLength: 1,
                                textAlign: TextAlign.center,
                                onChanged: (value) {
                                  viewModel.onCodeChanged(
                                      context, value, index);
                                },
                                inputFormatters: [
                                  UpperCaseTextFormatter(),
                                  LengthLimitingTextInputFormatter(1),
                                ],
                                decoration: const InputDecoration(
                                  counterText: "",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (viewModel.controllers.every(
                              (controller) => controller.text.isNotEmpty)) {
                            await viewModel.verifyEmail(
                              context,
                              "api/users/verify/verify-email",
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kod alanı eksik!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        child: const Text('Kaydı Tamamla'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
