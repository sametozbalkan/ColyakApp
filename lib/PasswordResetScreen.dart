import 'package:colyakapp/HttpBuild.dart';
import 'package:flutter/material.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  TextEditingController emailController = TextEditingController();

  Future<void> forgotPassword(String email) async {
    try {
      final response = await HttpBuildService.sendRequest(
          'POST', 'api/users/verify/x0/',
          body: {'email': email});

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-postanıza şifre sıfırlama linki gönderildi!'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
            "/loginscreen", (Route<dynamic> route) => false);
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email formatı yanlış veya bulunamadı!'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${response.statusCode}'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error resetting password: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  onChanged: (_) => setState(() {}),
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Emailinizi girin",
                    prefixIcon: const Icon(Icons.email),
                    border: const OutlineInputBorder(),
                    suffixIcon: emailController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () {
                              emailController.clear();
                              setState(() {});
                            },
                          ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: emailController.text.isEmpty
                    ? null
                    : () {
                        forgotPassword(emailController.text);
                      },
                child: const Text("Gönder"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
