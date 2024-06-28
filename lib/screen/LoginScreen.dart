import 'package:colyakapp/viewmodel/LoginViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      "assets/images/colyak.png",
                      height: MediaQuery.of(context).size.width / 1.5,
                      width: MediaQuery.of(context).size.width / 1.5,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Hoş Geldiniz",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        onChanged: (value) => viewModel.onEmailChanged(value),
                        controller: viewModel.emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email),
                          border: const OutlineInputBorder(),
                          suffixIcon: viewModel.emailController.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () => viewModel.clearEmail(),
                                ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        onChanged: (value) =>
                            viewModel.onPasswordChanged(value),
                        obscureText: viewModel.isVisible,
                        controller: viewModel.passwordController,
                        decoration: InputDecoration(
                          labelText: "Şifre",
                          prefixIcon: const Icon(Icons.password),
                          border: const OutlineInputBorder(),
                          suffixIcon:
                              viewModel.passwordController.text.isNotEmpty
                                  ? IconButton(
                                      icon: viewModel.isVisible
                                          ? const Icon(Icons.visibility_off)
                                          : const Icon(Icons.visibility),
                                      onPressed: viewModel.toggleVisibility,
                                    )
                                  : null,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            viewModel.showResetPassword(context);
                          },
                          child: const Text("Şifrenizi mi unuttunuz?"),
                        ),
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: viewModel.isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () async {
                                  await viewModel.login(context);
                                },
                                child: const Text("Giriş Yap"),
                              )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Henüz bir hesabınız yok mu?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/register");
                          },
                          child: const Text("Kayıt Ol"),
                        ),
                      ],
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
