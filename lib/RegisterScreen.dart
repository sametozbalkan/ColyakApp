import 'package:colyakapp/HttpBuild.dart';
import 'package:colyakapp/VerifyMail.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isVisible = true;
  bool isVisibleRepeat = true;
  Future<void> kayitOl(
      String email, String name, String password, String path) async {
    Map<String, dynamic> kayitDetay = {
      'email': email,
      'name': name,
      'password': password,
    };

    try {
      var kaydolResponse =
          await sendRequest('POST', path, body: kayitDetay, context: context);

      if (kaydolResponse.statusCode == 201) {
        print(kaydolResponse.body);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VerifyMail(verificationId: kaydolResponse.body),
          ),
        );
      } else {
        throw Exception('Kayıt işlemi başarısız oldu');
      }
    } catch (e) {
      print('Hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt işlemi başarısız oldu'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordControllerRepeat = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ekranı')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                onChanged: (_) => setState(() {}),
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "İsim",
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                  suffixIcon: nameController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () {
                            nameController.clear();
                            setState(() {});
                          },
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                onChanged: (_) => setState(() {}),
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                onChanged: (_) => setState(() {}),
                obscureText: isVisible,
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Şifre",
                  prefixIcon: const Icon(Icons.password),
                  border: const OutlineInputBorder(),
                  suffixIcon: passwordController.text.isNotEmpty
                      ? IconButton(
                          icon: isVisible
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                          onPressed: () {
                            setState(() => isVisible = !isVisible);
                          },
                        )
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                onChanged: (_) => setState(() {}),
                obscureText: isVisibleRepeat,
                controller: passwordControllerRepeat,
                decoration: InputDecoration(
                  labelText: "Şifre Tekrar",
                  prefixIcon: const Icon(Icons.password),
                  border: const OutlineInputBorder(),
                  suffixIcon: passwordControllerRepeat.text.isNotEmpty
                      ? IconButton(
                          icon: isVisibleRepeat
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                          onPressed: () {
                            setState(() => isVisibleRepeat = !isVisibleRepeat);
                          },
                        )
                      : null,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (passwordController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    nameController.text.isNotEmpty &&
                    passwordControllerRepeat.text.isNotEmpty) {
                  if ((passwordController.text ==
                      passwordControllerRepeat.text)) {
                    await kayitOl(
                      emailController.text,
                      nameController.text,
                      passwordController.text,
                      "api/users/verify/create",
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Şifreler uyuşmuyor!'),
                        duration: Duration(seconds: 1),
                      ),
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
    );
  }
}
