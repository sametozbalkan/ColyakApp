import 'package:colyakapp/viewmodel/RegisterViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegisterViewModel(),
      child: Consumer<RegisterViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(title: const Text('Kayıt Ekranı')),
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      "assets/images/colyak.png",
                      height: MediaQuery.of(context).size.width / 2,
                      width: MediaQuery.of(context).size.width / 2,
                    ),
                    const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("Size nasıl hitap edelim?",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 10),
                    buildTextField(
                      labelText: "İsim Soyisim",
                      prefixIcon: Icons.person,
                      controller: viewModel.nameController,
                    ),
                    buildTextField(
                      labelText: "Email",
                      prefixIcon: Icons.email,
                      controller: viewModel.emailController,
                    ),
                    buildTextField(
                      labelText: "Şifre",
                      prefixIcon: Icons.password,
                      controller: viewModel.passwordController,
                      obscureText: viewModel.isVisible,
                      onSuffixIconPressed: () {
                        viewModel.toggleVisibility();
                      },
                    ),
                    buildTextField(
                      labelText: "Şifre Tekrar",
                      prefixIcon: Icons.password,
                      controller: viewModel.passwordControllerRepeat,
                      obscureText: viewModel.isVisibleRepeat,
                      onSuffixIconPressed: () {
                        viewModel.toggleVisibilityRepeat();
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (viewModel.areFieldsNotEmpty()) {
                          if (!viewModel.isPasswordValid()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Şifre en az 8 karakter olmalıdır!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          } else if (!viewModel.arePasswordsMatching()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Şifreler uyuşmuyor!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          } else {
                            await viewModel.register(
                              context,
                              "api/users/verify/create",
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Boş alan bırakmayın!'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      child: const Text('Kayıt Ol'),
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

  Widget buildTextField({
    required String labelText,
    required IconData prefixIcon,
    required TextEditingController controller,
    bool obscureText = false,
    void Function()? onSuffixIconPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 10, bottom: 15),
      child: TextField(
        onChanged: (_) {},
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(prefixIcon),
          border: const OutlineInputBorder(),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: obscureText
                      ? const Icon(Icons.visibility_off)
                      : const Icon(Icons.cancel),
                  onPressed: onSuffixIconPressed ??
                      () {
                        controller.clear();
                      },
                ),
        ),
      ),
    );
  }
}
