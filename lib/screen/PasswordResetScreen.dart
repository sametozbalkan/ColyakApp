import 'package:colyakapp/viewmodel/PasswordResetViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordResetScreen extends StatelessWidget {
  const PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PasswordResetViewModel(),
      child: Consumer<PasswordResetViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(title: const Text("Şifre Sıfırlama")),
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/colyak.png",
                        height: MediaQuery.of(context).size.width / 2,
                        width: MediaQuery.of(context).size.width / 2),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                      child: TextField(
                        onChanged: (value) => viewModel.onEmailChanged(value),
                        controller: viewModel.emailController,
                        decoration: InputDecoration(
                          labelText: "Emailinizi girin",
                          prefixIcon: const Icon(Icons.email),
                          border: const OutlineInputBorder(),
                          suffixIcon: viewModel.emailController.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () {
                                    viewModel.emailController.clear();
                                    viewModel.clearEmail();
                                  },
                                ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: viewModel.emailController.text.isEmpty
                          ? null
                          : () {
                              viewModel.forgotPassword(
                                  context, viewModel.emailController.text);
                            },
                      child: viewModel.isLoading
                          ? const CircularProgressIndicator()
                          : const Text("Gönder"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
