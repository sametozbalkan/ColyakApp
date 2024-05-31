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

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordControllerRepeat =
      TextEditingController();

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt işlemi başarısız oldu'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget buildTextField({
    required String labelText,
    required IconData prefixIcon,
    required TextEditingController controller,
    bool obscureText = false,
    void Function()? onSuffixIconPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
      child: TextField(
        onChanged: (_) => setState(() {}),
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
                        setState(() {});
                      },
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ekranı')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Image.asset(
                "assets/images/colyak.png",
                height: MediaQuery.of(context).size.width / 1.5,
                width: MediaQuery.of(context).size.width / 1.5,
              ),
              const SizedBox(height: 10),
              buildTextField(
                labelText: "İsim",
                prefixIcon: Icons.person,
                controller: nameController,
              ),
              buildTextField(
                labelText: "Email",
                prefixIcon: Icons.email,
                controller: emailController,
              ),
              buildTextField(
                labelText: "Şifre",
                prefixIcon: Icons.password,
                controller: passwordController,
                obscureText: isVisible,
                onSuffixIconPressed: () {
                  setState(() => isVisible = !isVisible);
                },
              ),
              buildTextField(
                labelText: "Şifre Tekrar",
                prefixIcon: Icons.password,
                controller: passwordControllerRepeat,
                obscureText: isVisibleRepeat,
                onSuffixIconPressed: () {
                  setState(() => isVisibleRepeat = !isVisibleRepeat);
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (passwordController.text.isNotEmpty &&
                      emailController.text.isNotEmpty &&
                      nameController.text.isNotEmpty &&
                      passwordControllerRepeat.text.isNotEmpty) {
                    if (passwordController.text.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Şifre en az 8 karakter olmalıdır!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    } else if (passwordController.text !=
                        passwordControllerRepeat.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Şifreler uyuşmuyor!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    } else {
                      await kayitOl(
                        emailController.text,
                        nameController.text,
                        passwordController.text,
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
  }
}
