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
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  "Şifremi Unuttum",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
              viewModel.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(6),
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: viewModel.emailController.text.isEmpty
                          ? null
                          : () {
                              viewModel.forgotPassword(
                                  context, viewModel.emailController.text);
                            },
                      child: const Text("Gönder"),
                    )
            ],
          );
        },
      ),
    );
  }
}
